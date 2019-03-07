# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

require 'seth/ceth'

class Seth
  class ceth
    class CookbookSiteShare < ceth

      deps do
        require 'seth/cookbook_loader'
        require 'seth/cookbook_uploader'
        require 'seth/cookbook_site_streaming_uploader'
      end

      banner "ceth cookbook site share COOKBOOK CATEGORY (options)"
      category "cookbook site"

      option :cookbook_path,
        :short => "-o PATH:PATH",
        :long => "--cookbook-path PATH:PATH",
        :description => "A colon-separated path to look for cookbooks in",
        :proc => lambda { |o| Seth::Config.cookbook_path = o.split(":") }

      def run
        if @name_args.length < 2
          show_usage
          ui.fatal("You must specify the cookbook name and the category you want to share this cookbook to.")
          exit 1
        end

        config[:cookbook_path] ||= Seth::Config[:cookbook_path]

        cookbook_name = @name_args[0]
        category = @name_args[1]
        cl = Seth::CookbookLoader.new(config[:cookbook_path])
        if cl.cookbook_exists?(cookbook_name)
          cookbook = cl[cookbook_name]
          Seth::CookbookUploader.new(cookbook,config[:cookbook_path]).validate_cookbooks
          tmp_cookbook_dir = Seth::CookbookSiteStreamingUploader.create_build_dir(cookbook)
          begin
            Seth::Log.debug("Temp cookbook directory is #{tmp_cookbook_dir.inspect}")
            ui.info("Making tarball #{cookbook_name}.tgz")
            Seth::Mixin::Command.run_command(:command => "tar -czf #{cookbook_name}.tgz #{cookbook_name}", :cwd => tmp_cookbook_dir)
          rescue => e
            ui.error("Error making tarball #{cookbook_name}.tgz: #{e.message}. Increase log verbosity (-VV) for more information.")
            Seth::Log.debug("\n#{e.backtrace.join("\n")}")
            exit(1)
          end

          begin
            do_upload("#{tmp_cookbook_dir}/#{cookbook_name}.tgz", category, Seth::Config[:node_name], seth::Config[:client_key])
            ui.info("Upload complete!")
            Seth::Log.debug("Removing local staging directory at #{tmp_cookbook_dir}")
            FileUtils.rm_rf tmp_cookbook_dir
          rescue => e
            ui.error("Error uploading cookbook #{cookbook_name} to the Opscode Cookbook Site: #{e.message}. Increase log verbosity (-VV) for more information.")
            Seth::Log.debug("\n#{e.backtrace.join("\n")}")
            exit(1)
          end

        else
          ui.error("Could not find cookbook #{cookbook_name} in your cookbook path.")
          exit(1)
        end

      end

      def do_upload(cookbook_filename, cookbook_category, user_id, user_secret_filename)
         uri = "http://cookbooks.opscode.com/api/v1/cookbooks"

         category_string = { 'category'=>cookbook_category }.to_json

         http_resp = Seth::CookbookSiteStreamingUploader.post(uri, user_id, user_secret_filename, {
           :tarball => File.open(cookbook_filename),
           :cookbook => category_string
         })

         res = Seth::JSONCompat.from_json(http_resp.body)
         if http_resp.code.to_i != 201
           if res['error_messages']
             if res['error_messages'][0] =~ /Version already exists/
               ui.error "The same version of this cookbook already exists on the Opscode Cookbook Site."
               exit(1)
             else
               ui.error "#{res['error_messages'][0]}"
               exit(1)
             end
           else
             ui.error "Unknown error while sharing cookbook"
             ui.error "Server response: #{http_resp.body}"
             exit(1)
           end
         end
         res
       end
    end

  end
end
