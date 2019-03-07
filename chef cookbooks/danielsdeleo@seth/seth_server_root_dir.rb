#
# Author:: John Keiser (<jkeiser@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

require 'seth/server_api'
require 'seth/seth_fs/file_system/acls_dir'
require 'seth/seth_fs/file_system/base_fs_dir'
require 'seth/seth_fs/file_system/rest_list_dir'
require 'seth/seth_fs/file_system/cookbooks_dir'
require 'seth/seth_fs/file_system/data_bags_dir'
require 'seth/seth_fs/file_system/nodes_dir'
require 'seth/seth_fs/file_system/environments_dir'
require 'seth/seth_fs/data_handler/client_data_handler'
require 'seth/seth_fs/data_handler/role_data_handler'
require 'seth/seth_fs/data_handler/user_data_handler'
require 'seth/seth_fs/data_handler/group_data_handler'
require 'seth/seth_fs/data_handler/container_data_handler'

class Seth
  module SethFS
    module FileSystem
      class SethServerRootDir < BaseFSDir
        def initialize(root_name, seth_config, options = {})
          super("", nil)
          @seth_server_url = seth_config[:seth_server_url]
          @seth_username = seth_config[:node_name]
          @seth_private_key = seth_config[:client_key]
          @environment = seth_config[:environment]
          @repo_mode = seth_config[:repo_mode]
          @root_name = root_name
          @cookbook_version = options[:cookbook_version] # Used in ceth diff and download for server cookbook version
        end

        attr_reader :seth_server_url
        attr_reader :seth_username
        attr_reader :seth_private_key
        attr_reader :environment
        attr_reader :repo_mode
        attr_reader :cookbook_version

        def fs_description
          "Seth server at #{seth_server_url} (user #{seth_username}), repo_mode = #{repo_mode}"
        end

        def rest
          Seth::ServerAPI.new(seth_server_url, :client_name => seth_username, :signing_key_filename => seth_private_key, :raw_output => true)
        end

        def get_json(path)
          Seth::ServerAPI.new(seth_server_url, :client_name => seth_username, :signing_key_filename => seth_private_key).get(path)
        end

        def seth_rest
          Seth::REST.new(seth_server_url, seth_username, seth_private_key)
        end

        def api_path
          ""
        end

        def path_for_printing
          "#{@root_name}/"
        end

        def can_have_child?(name, is_dir)
          is_dir && children.any? { |child| child.name == name }
        end

        def org
          @org ||= if URI.parse(seth_server_url).path =~ /^\/+organizations\/+([^\/]+)$/
            $1
          else
            nil
          end
        end

        def children
          @children ||= begin
            result = [
              CookbooksDir.new(self),
              DataBagsDir.new(self),
              EnvironmentsDir.new(self),
              RestListDir.new("roles", self, nil, Seth::sethFS::DataHandler::RoleDataHandler.new)
            ]
            if repo_mode == 'hosted_everything'
              result += [
                AclsDir.new(self),
                RestListDir.new("clients", self, nil, Seth::sethFS::DataHandler::ClientDataHandler.new),
                RestListDir.new("containers", self, nil, Seth::sethFS::DataHandler::ContainerDataHandler.new),
                RestListDir.new("groups", self, nil, Seth::sethFS::DataHandler::GroupDataHandler.new),
                NodesDir.new(self)
              ]
            elsif repo_mode != 'static'
              result += [
                RestListDir.new("clients", self, nil, Seth::sethFS::DataHandler::ClientDataHandler.new),
                NodesDir.new(self),
                RestListDir.new("users", self, nil, Seth::sethFS::DataHandler::UserDataHandler.new)
              ]
            end
            result.sort_by { |child| child.name }
          end
        end
      end
    end
  end
end
