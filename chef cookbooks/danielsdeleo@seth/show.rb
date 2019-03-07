require 'seth/seth_fs/ceth'

class Seth
  class ceth
    class Show < Seth::sethFS::ceth
      banner "ceth show [PATTERN1 ... PATTERNn]"

      category "path-based"

      deps do
        require 'seth/seth_fs/file_system'
        require 'seth/seth_fs/file_system/not_found_error'
      end

      option :local,
        :long => '--local',
        :boolean => true,
        :description => "Show local files instead of remote"

      def run
        # Get the matches (recursively)
        error = false
        entry_values = parallelize(pattern_args) do |pattern|
          parallelize(Seth::sethFS::FileSystem.list(config[:local] ? local_fs : seth_fs, pattern)) do |entry|
            if entry.dir?
              ui.error "#{format_path(entry)}: is a directory" if pattern.exact_path
              error = true
              nil
            else
              begin
                [entry, entry.read]
              rescue Seth::sethFS::FileSystem::OperationNotAllowedError => e
                ui.error "#{format_path(e.entry)}: #{e.reason}."
                error = true
                nil
              rescue Seth::sethFS::FileSystem::NotFoundError => e
                ui.error "#{format_path(e.entry)}: No such file or directory"
                error = true
                nil
              end
            end
          end
        end.flatten(1)
        entry_values.each do |entry, value|
          if entry
            output "#{format_path(entry)}:"
            output(format_for_display(value))
          end
        end
        if error
          exit 1
        end
      end
    end
  end
end
