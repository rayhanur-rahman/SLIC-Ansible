#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

require 'seth/run_list'
class Seth
  class ceth
    module Core
      # Instances of BootstrapContext are the context objects (i.e., +self+) for
      # bootstrap templates. For backwards compatability, they +must+ set the
      # following instance variables:
      # * @config   - a hash of ceth's config values
      # * @run_list - the run list for the node to boostrap
      #
      class BootstrapContext

        def initialize(config, run_list, seth_config)
          @config       = config
          @run_list     = run_list
          @seth_config  = seth_config
        end

        def bootstrap_version_string
          if @config[:prerelease]
            "--prerelease"
          else
            "--version #{seth_version}"
          end
        end

        def bootstrap_environment
          @seth_config[:environment] || '_default'
        end

        def validation_key
          IO.read(File.expand_path(@seth_config[:validation_key]))
        end

        def encrypted_data_bag_secret
          ceth_config[:secret] || begin
            if ceth_config[:secret_file] && File.exist?(ceth_config[:secret_file])
              IO.read(File.expand_path(ceth_config[:secret_file]))
            elsif @seth_config[:encrypted_data_bag_secret] && File.exist?(@seth_config[:encrypted_data_bag_secret])
              IO.read(File.expand_path(@seth_config[:encrypted_data_bag_secret]))
            end
          end
        end

        def config_content
          client_rb = <<-CONFIG
log_location     STDOUT
seth_server_url  "#{@seth_config[:seth_server_url]}"
validation_client_name "#{@seth_config[:validation_client_name]}"
CONFIG
          if @config[:seth_node_name]
            client_rb << %Q{node_name "#{@config[:seth_node_name]}"\n}
          else
            client_rb << "# Using default node name (fqdn)\n"
          end

          if ceth_config[:bootstrap_proxy]
            client_rb << %Q{http_proxy        "#{ceth_config[:bootstrap_proxy]}"\n}
            client_rb << %Q{https_proxy       "#{ceth_config[:bootstrap_proxy]}"\n}
          end

          if ceth_config[:bootstrap_no_proxy]
            client_rb << %Q{no_proxy       "#{ceth_config[:bootstrap_no_proxy]}"\n}
          end

          if encrypted_data_bag_secret
            client_rb << %Q{encrypted_data_bag_secret "/etc/seth/encrypted_data_bag_secret"\n}
          end

          client_rb
        end

        def start_seth
          # If the user doesn't have a client path configure, let bash use the PATH for what it was designed for
          client_path = @seth_config[:seth_client_path] || 'seth-client'
          s = "#{client_path} -j /etc/seth/first-boot.json"
          s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
          s << " -E #{bootstrap_environment}" if seth_version.to_f != 0.9 # only use the -E option on Seth 0.10+
          s
        end

        def ceth_config
          @seth_config.key?(:ceth) ? @seth_config[:ceth] : {}
        end

        #
        # This function is used by older bootstrap templates other than seth-full
        # and potentially by custom templates as well hence it's logic needs to be
        # preserved for backwards compatibility reasons until we hit Seth 12.
        def seth_version
          ceth_config[:bootstrap_version] || Seth::VERSION
        end

        #
        # seth version string to fetch the latest current version from omnitruck
        # If user is on X.Y.Z bootstrap will use the latest X release
        # X here can be 10 or 11
        def latest_current_seth_version_string
          seth_version_string = if ceth_config[:bootstrap_version]
            ceth_config[:bootstrap_version]
          else
            Seth::VERSION.split(".").first
          end

          installer_version_string = ["-v", seth_version_string]

          # If bootstrapping a pre-release version add -p to the installer string
          if seth_version_string.split(".").length > 3
            installer_version_string << "-p"
          end

          installer_version_string.join(" ")
        end

        def first_boot
          (@config[:first_boot_attributes] || {}).merge(:run_list => @run_list)
        end

      end
    end
  end
end
