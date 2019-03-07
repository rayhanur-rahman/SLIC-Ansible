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
require 'seth/seth_fs/file_system/seth_repository_file_system_entry'
require 'seth/seth_fs/file_system/seth_repository_file_system_acls_dir'
require 'seth/seth_fs/file_system/seth_repository_file_system_cookbooks_dir'
require 'seth/seth_fs/file_system/seth_repository_file_system_data_bags_dir'
require 'seth/seth_fs/file_system/multiplexed_dir'
require 'seth/seth_fs/data_handler/client_data_handler'
require 'seth/seth_fs/data_handler/environment_data_handler'
require 'seth/seth_fs/data_handler/node_data_handler'
require 'seth/seth_fs/data_handler/role_data_handler'
require 'seth/seth_fs/data_handler/user_data_handler'
require 'seth/seth_fs/data_handler/group_data_handler'
require 'seth/seth_fs/data_handler/container_data_handler'

class Seth
  module SethFS
    module FileSystem
      class SethRepositoryFileSystemRootDir < BaseFSDir
        def initialize(child_paths)
          super("", nil)
          @child_paths = child_paths
        end

        attr_accessor :write_pretty_json

        attr_reader :child_paths

        def children
          @children ||= child_paths.keys.sort.map { |name| make_child_entry(name) }.select { |child| !child.nil? }
        end

        def can_have_child?(name, is_dir)
          child_paths.has_key?(name) && is_dir
        end

        def create_child(name, file_contents = nil)
          child_paths[name].each do |path|
            begin
              Dir.mkdir(path)
            rescue Errno::EEXIST
            end
          end
          child = make_child_entry(name)
          @children = nil
          child
        end

        def json_class
          nil
        end

        # Used to print out the filesystem
        def fs_description
          repo_path = File.dirname(child_paths['cookbooks'][0])
          result = "repository at #{repo_path}\n"
          if Seth::Config[:versioned_cookbooks]
            result << "  Multiple versions per cookbook\n"
          else
            result << "  One version per cookbook\n"
          end
          child_paths.each_pair do |name, paths|
            if paths.any? { |path| File.dirname(path) != repo_path }
              result << "  #{name} at #{paths.join(', ')}\n"
            end
          end
          result
        end

        private

        def make_child_entry(name)
          paths = child_paths[name].select do |path|
            File.exists?(path)
          end
          if paths.size == 0
            return nil
          end
          if name == 'cookbooks'
            dirs = paths.map { |path| SethRepositoryFileSystemCookbooksDir.new(name, self, path) }
          elsif name == 'data_bags'
            dirs = paths.map { |path| SethRepositoryFileSystemDataBagsDir.new(name, self, path) }
          elsif name == 'acls'
            dirs = paths.map { |path| SethRepositoryFileSystemAclsDir.new(name, self, path) }
          else
            data_handler = case name
              when 'clients'
                Seth::sethFS::DataHandler::ClientDataHandler.new
              when 'environments'
                Seth::sethFS::DataHandler::EnvironmentDataHandler.new
              when 'nodes'
                Seth::sethFS::DataHandler::NodeDataHandler.new
              when 'roles'
                Seth::sethFS::DataHandler::RoleDataHandler.new
              when 'users'
                Seth::sethFS::DataHandler::UserDataHandler.new
              when 'groups'
                Seth::sethFS::DataHandler::GroupDataHandler.new
              when 'containers'
                Seth::sethFS::DataHandler::ContainerDataHandler.new
              else
                raise "Unknown top level path #{name}"
              end
            dirs = paths.map { |path| SethRepositoryFileSystemEntry.new(name, self, path, data_handler) }
          end
          MultiplexedDir.new(dirs)
        end
      end
    end
  end
end
