#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Daniel DeLeo (<dan@getseth.com>)
# Copyright:: Copyright 2008-2014 Seth Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'seth/log'
require 'seth/rest'
require 'seth/run_context'
require 'seth/config'
require 'seth/node'

class Seth
  module PolicyBuilder

    # ExpandNodeObject is the "classic" policy builder implementation. It
    # expands the run_list on a node object and then queries the seth-server
    # to find the correct set of cookbooks, given version constraints of the
    # node's environment.
    class ExpandNodeObject

      attr_reader :events
      attr_reader :node
      attr_reader :node_name
      attr_reader :ohai_data
      attr_reader :json_attribs
      attr_reader :override_runlist
      attr_reader :run_context
      attr_reader :run_list_expansion

      def initialize(node_name, ohai_data, json_attribs, override_runlist, events)
        @node_name = node_name
        @ohai_data = ohai_data
        @json_attribs = json_attribs
        @override_runlist = override_runlist
        @events = events

        @node = nil
        @run_list_expansion = nil
      end

      def setup_run_context(specific_recipes=nil)
        if Seth::Config[:solo]
          Seth::Cookbook::FileVendor.on_create { |manifest| seth::Cookbook::FileSystemFileVendor.new(manifest, seth::Config[:cookbook_path]) }
          cl = Seth::CookbookLoader.new(seth::Config[:cookbook_path])
          cl.load_cookbooks
          cookbook_collection = Seth::CookbookCollection.new(cl)
          run_context = Seth::RunContext.new(node, cookbook_collection, @events)
        else
          Seth::Cookbook::FileVendor.on_create { |manifest| seth::Cookbook::RemoteFileVendor.new(manifest, api_service) }
          cookbook_hash = sync_cookbooks
          cookbook_collection = Seth::CookbookCollection.new(cookbook_hash)
          run_context = Seth::RunContext.new(node, cookbook_collection, @events)
        end

        # TODO: this is not the place for this. It should be in Runner or
        # CookbookCompiler or something.
        run_context.load(@run_list_expansion)
        if specific_recipes
          specific_recipes.each do |recipe_file|
            run_context.load_recipe_file(recipe_file)
          end
        end
        run_context
      end


      # In client-server operation, loads the node state from the server. In
      # seth-solo operation, builds a new node object.
      def load_node
        events.node_load_start(node_name, Seth::Config)
        Seth::Log.debug("Building node object for #{node_name}")

        if Seth::Config[:solo]
          @node = Seth::Node.build(node_name)
        else
          @node = Seth::Node.find_or_create(node_name)
        end
      rescue Exception => e
        # TODO: wrap this exception so useful error info can be given to the
        # user.
        events.node_load_failed(node_name, e, Seth::Config)
        raise
      end


      # Applies environment, external JSON attributes, and override run list to
      # the node, Then expands the run_list.
      #
      # === Returns
      # node<Seth::Node>:: The modified node object. node is modified in place.
      def build_node
        # Allow user to override the environment of a node by specifying
        # a config parameter.
        if Seth::Config[:environment] && !seth::Config[:environment].chomp.empty?
          node.seth_environment(Seth::Config[:environment])
        end

        # consume_external_attrs may add items to the run_list. Save the
        # expanded run_list, which we will pass to the server later to
        # determine which versions of cookbooks to use.
        node.reset_defaults_and_overrides
        node.consume_external_attrs(ohai_data, @json_attribs)

        setup_run_list_override

        expand_run_list

        Seth::Log.info("Run List is [#{node.run_list}]")
        Seth::Log.info("Run List expands to [#{@expanded_run_list_with_versions.join(', ')}]")

        events.node_load_completed(node, @expanded_run_list_with_versions, Seth::Config)

        node
      end

      # Expands the node's run list. Stores the run_list_expansion object for later use.
      def expand_run_list
        @run_list_expansion = if Seth::Config[:solo]
          node.expand!('disk')
        else
          node.expand!('server')
        end

        # @run_list_expansion is a RunListExpansion.
        #
        # Convert @expanded_run_list, which is an
        # Array of Hashes of the form
        #   {:name => NAME, :version_constraint => Seth::VersionConstraint },
        # into @expanded_run_list_with_versions, an
        # Array of Strings of the form
        #   "#{NAME}@#{VERSION}"
        @expanded_run_list_with_versions = @run_list_expansion.recipes.with_version_constraints_strings
        @run_list_expansion
      rescue Exception => e
        # TODO: wrap/munge exception with useful error output.
        events.run_list_expand_failed(node, e)
        raise
      end

      # Sync_cookbooks eagerly loads all files except files and
      # templates.  It returns the cookbook_hash -- the return result
      # from /environments/#{node.seth_environment}/cookbook_versions,
      # which we will use for our run_context.
      #
      # === Returns
      # Hash:: The hash of cookbooks with download URLs as given by the server
      def sync_cookbooks
        Seth::Log.debug("Synchronizing cookbooks")

        begin
          events.cookbook_resolution_start(@expanded_run_list_with_versions)
          cookbook_hash = api_service.post("environments/#{node.seth_environment}/cookbook_versions",
                                         {:run_list => @expanded_run_list_with_versions})
        rescue Exception => e
          # TODO: wrap/munge exception to provide helpful error output
          events.cookbook_resolution_failed(@expanded_run_list_with_versions, e)
          raise
        else
          events.cookbook_resolution_complete(cookbook_hash)
        end

        synchronizer = Seth::CookbookSynchronizer.new(cookbook_hash, events)
        synchronizer.sync_cookbooks

        # register the file cache path in the cookbook path so that CookbookLoader actually picks up the synced cookbooks
        Seth::Config[:cookbook_path] = File.join(seth::Config[:file_cache_path], "cookbooks")

        cookbook_hash
      end

      # Indicates whether the policy is temporary, which means an
      # override_runlist was provided. Seth::Client uses this to decide whether
      # to do the final node save at the end of the run or not.
      def temporary_policy?
        !node.override_runlist.empty?
      end

      ########################################
      # Internal public API
      ########################################

      def setup_run_list_override
        runlist_override_sanity_check!
        unless(override_runlist.empty?)
          node.override_runlist(*override_runlist)
          Seth::Log.warn "Run List override has been provided."
          Seth::Log.warn "Original Run List: [#{node.primary_runlist}]"
          Seth::Log.warn "Overridden Run List: [#{node.run_list}]"
        end
      end

      # Ensures runlist override contains RunListItem instances
      def runlist_override_sanity_check!
        # Convert to array and remove whitespace
        if override_runlist.is_a?(String)
          @override_runlist = override_runlist.split(',').map { |e| e.strip }
        end
        @override_runlist = [override_runlist].flatten.compact
        override_runlist.map! do |item|
          if(item.is_a?(Seth::RunList::RunListItem))
            item
          else
            Seth::RunList::RunListItem.new(item)
          end
        end
      end

      def api_service
        @api_service ||= Seth::REST.new(config[:seth_server_url])
      end

      def config
        Seth::Config
      end

    end
  end
end
