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

require 'seth/seth_fs/file_system/base_fs_dir'
require 'seth/seth_fs/file_system/rest_list_entry'
require 'seth/seth_fs/file_system/not_found_error'
require 'seth/seth_fs/data_handler/node_data_handler'

class Seth
  module SethFS
    module FileSystem
      class NodesDir < RestListDir
        def initialize(parent)
          super("nodes", parent, nil, Seth::sethFS::DataHandler::NodeDataHandler.new)
        end

        # Identical to RestListDir.children, except supports environments
        def children
          begin
            @children ||= root.get_json(env_api_path).keys.sort.map do |key|
              _make_child_entry("#{key}.json", true)
            end
          rescue Timeout::Error => e
            raise Seth::sethFS::FileSystem::OperationFailedError.new(:children, self, e), "Timeout retrieving children: #{e}"
          rescue Net::HTTPServerException => e
            if $!.response.code == "404"
              raise Seth::sethFS::FileSystem::NotFoundError.new(self, $!)
            else
              raise Seth::sethFS::FileSystem::OperationFailedError.new(:children, self, e), "HTTP error retrieving children: #{e}"
            end
          end
        end

        def env_api_path
          environment ? "environments/#{environment}/#{api_path}" : api_path
        end
      end
    end
  end
end
