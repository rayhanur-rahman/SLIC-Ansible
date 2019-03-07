require 'seth/seth_fs/ceth'

class Seth
  class ceth
    class Delete < Seth::sethFS::ceth
      banner "ceth delete [PATTERN1 ... PATTERNn]"

      category "path-based"

      deps do
        require 'seth/seth_fs/file_system'
      end

      option :recurse,
        :short => '-r',
        :long => '--[no-]recurse',
        :boolean => true,
        :default => false,
        :description => "Delete directories recursively."
      option :both,
        :long => '--both',
        :boolean => true,
        :default => false,
        :description => "Delete both the local and remote copies."
      option :local,
        :long => '--local',
        :boolean => true,
        :default => false,
        :description => "Delete the local copy (leave the remote copy)."

      def run
        if name_args.length == 0
          show_usage
          ui.fatal("Must specify at least one argument.  If you want to delete everything in this directory, type \"ceth delete --recurse .\"")
          exit 1
        end

        # Get the matches (recursively)
        error = false
        if config[:local]
          pattern_args.each do |pattern|
            Seth::sethFS::FileSystem.list(local_fs, pattern).each do |result|
              if delete_result(result)
                error = true
              end
            end
          end
        elsif config[:both]
          pattern_args.each do |pattern|
            Seth::sethFS::FileSystem.list_pairs(pattern, seth_fs, local_fs).each do |seth_result, local_result|
              if delete_result(seth_result, local_result)
                error = true
              end
            end
          end
        else # Remote only
          pattern_args.each do |pattern|
            Seth::sethFS::FileSystem.list(seth_fs, pattern).each do |result|
              if delete_result(result)
                error = true
              end
            end
          end
        end

        if error
          exit 1
        end
      end

      def format_path_with_root(entry)
        root = entry.root == seth_fs ? " (remote)" : " (local)"
        "#{format_path(entry)}#{root}"
      end

      def delete_result(*results)
        deleted_any = false
        found_any = false
        error = false
        results.each do |result|
          begin
            result.delete(config[:recurse])
            deleted_any = true
            found_any = true
          rescue Seth::sethFS::FileSystem::NotFoundError
            # This is not an error unless *all* of them were not found
          rescue Seth::sethFS::FileSystem::MustDeleteRecursivelyError => e
            ui.error "#{format_path_with_root(e.entry)} must be deleted recursively!  Pass -r to ceth delete."
            found_any = true
            error = true
          rescue Seth::sethFS::FileSystem::OperationNotAllowedError => e
            ui.error "#{format_path_with_root(e.entry)} #{e.reason}."
            found_any = true
            error = true
          end
        end
        if deleted_any
          output("Deleted #{format_path(results[0])}")
        elsif !found_any
          ui.error "#{format_path(results[0])}: No such file or directory"
          error = true
        end
        error
      end
    end
  end
end

