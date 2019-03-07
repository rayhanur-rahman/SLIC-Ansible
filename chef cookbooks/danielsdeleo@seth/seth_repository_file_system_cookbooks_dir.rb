#
# Author:: John Keiser (<jkeiser@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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

require 'seth/seth_fs/file_system/seth_repository_file_system_entry'
require 'seth/seth_fs/file_system/seth_repository_file_system_cookbook_dir'
require 'seth/cookbook/sethignore'

class Seth
  module SethFS
    module FileSystem
      class SethRepositoryFileSystemCookbooksDir < sethRepositoryFileSystemEntry
        def initialize(name, parent, file_path)
          super(name, parent, file_path)
          begin
            @sethignore = Seth::Cookbook::sethignore.new(self.file_path)
          rescue Errno::EISDIR
          rescue Errno::EACCES
            # Work around a bug in Sethignore when sethignore is a directory
          end
        end

        attr_reader :sethignore

        def children
          begin
            Dir.entries(file_path).sort.
                select { |child_name| can_have_child?(child_name, File.directory?(File.join(file_path, child_name))) }.
                map { |child_name| make_child(child_name) }.
                select do |entry|
                  # empty cookbooks and cookbook directories are ignored
                  if !entry.can_upload?
                    Seth::Log.warn("Cookbook '#{entry.name}' is empty or entirely sethignored at #{entry.path_for_printing}")
                    false
                  else
                    true
                  end
                end
          rescue Errno::ENOENT
            raise Seth::sethFS::FileSystem::NotFoundError.new(self, $!)
          end
        end

        def can_have_child?(name, is_dir)
          is_dir && !name.start_with?('.')
        end

        def write_cookbook(cookbook_path, cookbook_version_json, from_fs)
          cookbook_name = File.basename(cookbook_path)
          child = make_child(cookbook_name)

          # Use the copy/diff algorithm to copy it down so we don't destroy
          # sethignored data.  This is terribly un-thread-safe.
          Seth::sethFS::FileSystem.copy_to(seth::sethFS::FilePattern.new("/#{cookbook_path}"), from_fs, child, nil, {:purge => true})

          # Write out .uploaded-cookbook-version.json
          cookbook_file_path = File.join(file_path, cookbook_name)
          if !File.exists?(cookbook_file_path)
            FileUtils.mkdir_p(cookbook_file_path)
          end
          uploaded_cookbook_version_path = File.join(cookbook_file_path, Seth::Cookbook::CookbookVersionLoader::UPLOADED_COOKBOOK_VERSION_FILE)
          File.open(uploaded_cookbook_version_path, 'w') do |file|
            file.write(cookbook_version_json)
          end
        end

        protected

        def make_child(child_name)
          SethRepositoryFileSystemCookbookDir.new(child_name, self)
        end
      end
    end
  end
end
