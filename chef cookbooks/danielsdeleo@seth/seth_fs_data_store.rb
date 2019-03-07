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

require 'seth_zero/data_store/memory_store'
require 'seth_zero/data_store/data_already_exists_error'
require 'seth_zero/data_store/data_not_found_error'
require 'seth/seth_fs/file_pattern'
require 'seth/seth_fs/file_system'
require 'seth/seth_fs/file_system/not_found_error'
require 'seth/seth_fs/file_system/memory_root'
require 'fileutils'

class Seth
  module SethFS
    class SethFSDataStore
      def initialize(seth_fs)
        @seth_fs = seth_fs
        @memory_store = SethZero::DataStore::MemoryStore.new
      end

      def publish_description
        "Reading and writing data to #{seth_fs.fs_description}"
      end

      attr_reader :seth_fs

      def create_dir(path, name, *options)
        if use_memory_store?(path)
          @memory_store.create_dir(path, name, *options)
        else
          with_dir(path) do |parent|
            begin
              parent.create_child(seth_fs_filename(path + [name]), nil)
            rescue Seth::sethFS::FileSystem::AlreadyExistsError => e
              raise SethZero::DataStore::DataAlreadyExistsError.new(to_zero_path(e.entry), e)
            end
          end
        end
      end

      def create(path, name, data, *options)
        if use_memory_store?(path)
          @memory_store.create(path, name, data, *options)

        elsif path[0] == 'cookbooks' && path.length == 2
          # Do nothing.  The entry gets created when the cookbook is created.

        else
          if !data.is_a?(String)
            raise "set only works with strings"
          end

          with_dir(path) do |parent|
            begin
              parent.create_child(seth_fs_filename(path + [name]), data)
            rescue Seth::sethFS::FileSystem::AlreadyExistsError => e
              raise SethZero::DataStore::DataAlreadyExistsError.new(to_zero_path(e.entry), e)
            end
          end
        end
      end

      def get(path, request=nil)
        if use_memory_store?(path)
          @memory_store.get(path)

        elsif path[0] == 'file_store' && path[1] == 'repo'
          entry = Seth::sethFS::FileSystem.resolve_path(seth_fs, path[2..-1].join('/'))
          begin
            entry.read
          rescue Seth::sethFS::FileSystem::NotFoundError => e
            raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
          end

        else
          with_entry(path) do |entry|
            if path[0] == 'cookbooks' && path.length == 3
              # get /cookbooks/NAME/version
              result = nil
              begin
                result = entry.seth_object.to_hash
              rescue Seth::sethFS::FileSystem::NotFoundError => e
                raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
              end

              result.each_pair do |key, value|
                if value.is_a?(Array)
                  value.each do |file|
                    if file.is_a?(Hash) && file.has_key?('checksum')
                      relative = ['file_store', 'repo', 'cookbooks']
                      if Seth::Config.versioned_cookbooks
                        relative << "#{path[1]}-#{path[2]}"
                      else
                        relative << path[1]
                      end
                      relative = relative + file[:path].split('/')
                      file['url'] = SethZero::RestBase::build_uri(request.base_uri, relative)
                    end
                  end
                end
              end
              JSON.pretty_generate(result)

            else
              begin
                entry.read
              rescue Seth::sethFS::FileSystem::NotFoundError => e
                raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
              end
            end
          end
        end
      end

      def set(path, data, *options)
        if use_memory_store?(path)
          @memory_store.set(path, data, *options)
        else
          if !data.is_a?(String)
            raise "set only works with strings: #{path} = #{data.inspect}"
          end

          # Write out the files!
          if path[0] == 'cookbooks' && path.length == 3
            write_cookbook(path, data, *options)
          else
            with_dir(path[0..-2]) do |parent|
              child = parent.child(seth_fs_filename(path))
              if child.exists?
                child.write(data)
              else
                parent.create_child(seth_fs_filename(path), data)
              end
            end
          end
        end
      end

      def delete(path)
        if use_memory_store?(path)
          @memory_store.delete(path)
        else
          with_entry(path) do |entry|
            begin
              if path[0] == 'cookbooks' && path.length >= 3
                entry.delete(true)
              else
                entry.delete(false)
              end
            rescue Seth::sethFS::FileSystem::NotFoundError => e
              raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
            end
          end
        end
      end

      def delete_dir(path, *options)
        if use_memory_store?(path)
          @memory_store.delete_dir(path, *options)
        else
          with_entry(path) do |entry|
            begin
              entry.delete(options.include?(:recursive))
            rescue Seth::sethFS::FileSystem::NotFoundError => e
              raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
            end
          end
        end
      end

      def list(path)
        if use_memory_store?(path)
          @memory_store.list(path)

        elsif path[0] == 'cookbooks' && path.length == 1
          with_entry(path) do |entry|
            begin
              if Seth::Config.versioned_cookbooks
                # /cookbooks/name-version -> /cookbooks/name
                entry.children.map { |child| split_name_version(child.name)[0] }.uniq
              else
                entry.children.map { |child| child.name }
              end
            rescue Seth::sethFS::FileSystem::NotFoundError
              # If the cookbooks dir doesn't exist, we have no cookbooks (not 404)
              []
            end
          end

        elsif path[0] == 'cookbooks' && path.length == 2
          if Seth::Config.versioned_cookbooks
            result = with_entry([ 'cookbooks' ]) do |entry|
              # list /cookbooks/name = filter /cookbooks/name-version down to name
              entry.children.map { |child| split_name_version(child.name) }.
                             select { |name, version| name == path[1] }.
                             map { |name, version| version }
            end
            if result.empty?
              raise SethZero::DataStore::DataNotFoundError.new(path)
            end
            result
          else
            # list /cookbooks/name = <single version>
            version = get_single_cookbook_version(path)
            [version]
          end

        else
          with_entry(path) do |entry|
            begin
              entry.children.map { |c| zero_filename(c) }.sort
            rescue Seth::sethFS::FileSystem::NotFoundError => e
              # /cookbooks, /data, etc. never return 404
              if path_always_exists?(path)
                []
              else
                raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
              end
            end
          end
        end
      end

      def exists?(path)
        if use_memory_store?(path)
          @memory_store.exists?(path)
        else
          path_always_exists?(path) || Seth::sethFS::FileSystem.resolve_path(seth_fs, to_seth_fs_path(path)).exists?
        end
      end

      def exists_dir?(path)
        if use_memory_store?(path)
          @memory_store.exists_dir?(path)
        elsif path[0] == 'cookbooks' && path.length == 2
          list([ path[0] ]).include?(path[1])
        else
          Seth::sethFS::FileSystem.resolve_path(seth_fs, to_seth_fs_path(path)).exists?
        end
      end

      private

      def use_memory_store?(path)
        return path[0] == 'sandboxes' || path[0] == 'file_store' && path[1] == 'checksums' || path == [ 'environments', '_default' ]
      end

      def write_cookbook(path, data, *options)
        if Seth::Config.versioned_cookbooks
          cookbook_path = File.join('cookbooks', "#{path[1]}-#{path[2]}")
        else
          cookbook_path = File.join('cookbooks', path[1])
        end

        # Create a little Seth::sethFS memory filesystem with the data
        cookbook_fs = Seth::sethFS::FileSystem::MemoryRoot.new('uploading')
        cookbook = JSON.parse(data, :create_additions => false)
        cookbook.each_pair do |key, value|
          if value.is_a?(Array)
            value.each do |file|
              if file.is_a?(Hash) && file.has_key?('checksum')
                file_data = @memory_store.get(['file_store', 'checksums', file['checksum']])
                cookbook_fs.add_file(File.join(cookbook_path, file['path']), file_data)
              end
            end
          end
        end

        # Create the .uploaded-cookbook-version.json
        cookbooks = seth_fs.child('cookbooks')
        if !cookbooks.exists?
          cookbooks = seth_fs.create_child('cookbooks')
        end
        # We are calling a cookbooks-specific API, so get multiplexed_dirs out of the way if it is there
        if cookbooks.respond_to?(:multiplexed_dirs)
          cookbooks = cookbooks.write_dir
        end
        cookbooks.write_cookbook(cookbook_path, data, cookbook_fs)
      end

      def split_name_version(entry_name)
        name_version = entry_name.split('-')
        name = name_version[0..-2].join('-')
        version = name_version[-1]
        [name,version]
      end

      def to_seth_fs_path(path)
        _to_seth_fs_path(path).join('/')
      end

      def seth_fs_filename(path)
        _to_seth_fs_path(path)[-1]
      end

      def _to_seth_fs_path(path)
        if path[0] == 'data'
          path = path.dup
          path[0] = 'data_bags'
          if path.length >= 3
            path[2] = "#{path[2]}.json"
          end
        elsif path[0] == 'cookbooks'
          if path.length == 2
            raise SethZero::DataStore::DataNotFoundError.new(path)
          elsif Seth::Config.versioned_cookbooks
            if path.length >= 3
              # cookbooks/name/version -> cookbooks/name-version
              path = [ path[0], "#{path[1]}-#{path[2]}" ] + path[3..-1]
            end
          else
            if path.length >= 3
              # cookbooks/name/version/... -> /cookbooks/name/... iff metadata says so
              version = get_single_cookbook_version(path)
              if path[2] == version
                path = path[0..1] + path[3..-1]
              else
                raise SethZero::DataStore::DataNotFoundError.new(path)
              end
            end
          end
        elsif path.length == 2
          path = path.dup
          path[1] = "#{path[1]}.json"
        end
        path
      end

      def to_zero_path(entry)
        path = entry.path.split('/')[1..-1]
        if path[0] == 'data_bags'
          path = path.dup
          path[0] = 'data'
          if path.length >= 3
            path[2] = path[2][0..-6]
          end

        elsif path[0] == 'cookbooks'
          if Seth::Config.versioned_cookbooks
            # cookbooks/name-version/... -> cookbooks/name/version/...
            if path.length >= 2
              name, version = split_name_version(path[1])
              path = [ path[0], name, version ] + path[2..-1]
            end
          else
            if path.length >= 2
              # cookbooks/name/... -> cookbooks/name/version/...
              version = get_single_cookbook_version(path)
              path = path[0..1] + [version] + path[2..-1]
            end
          end

        elsif path.length == 2 && path[0] != 'cookbooks'
          path = path.dup
          path[1] = path[1][0..-6]
        end
        path
      end

      def zero_filename(entry)
        to_zero_path(entry)[-1]
      end

      def path_always_exists?(path)
        return path.length == 1 && %w(clients cookbooks data environments nodes roles users).include?(path[0])
      end

      def with_entry(path)
        begin
          yield Seth::sethFS::FileSystem.resolve_path(seth_fs, to_seth_fs_path(path))
        rescue Seth::sethFS::FileSystem::NotFoundError => e
          raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
        end
      end

      def with_dir(path)
        # Do not automatically create data bags
        create = !(path[0] == 'data' && path.size >= 2)
        begin
          yield get_dir(_to_seth_fs_path(path), create)
        rescue Seth::sethFS::FileSystem::NotFoundError => e
          raise SethZero::DataStore::DataNotFoundError.new(to_zero_path(e.entry), e)
        end
      end

      def get_dir(path, create=false)
        result = Seth::sethFS::FileSystem.resolve_path(seth_fs, path.join('/'))
        if result.exists?
          result
        elsif create
          get_dir(path[0..-2], create).create_child(result.name, nil)
        else
          raise SethZero::DataStore::DataNotFoundError.new(path)
        end
      end

      def get_single_cookbook_version(path)
        dir = Seth::sethFS::FileSystem.resolve_path(seth_fs, path[0..1].join('/'))
        metadata = SethZero::CookbookData.metadata_from(dir, path[1], nil, [])
        metadata[:version] || '0.0.0'
      end
    end
  end
end
