require 'seth/seth_fs/ceth'

class Seth
  class ceth
    class Edit < Seth::sethFS::ceth
      banner "ceth edit [PATTERN1 ... PATTERNn]"

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
        pattern_args.each do |pattern|
          Seth::sethFS::FileSystem.list(config[:local] ? local_fs : seth_fs, pattern).each do |result|
            if result.dir?
              ui.error "#{format_path(result)}: is a directory" if pattern.exact_path
              error = true
            else
              begin
                new_value = edit_text(result.read, File.extname(result.name))
                if new_value
                  result.write(new_value)
                  output "Updated #{format_path(result)}"
                else
                  output "#{format_path(result)} unchanged!"
                end
              rescue Seth::sethFS::FileSystem::OperationNotAllowedError => e
                ui.error "#{format_path(e.entry)}: #{e.reason}."
                error = true
              rescue Seth::sethFS::FileSystem::NotFoundError => e
                ui.error "#{format_path(e.entry)}: No such file or directory"
                error = true
              end
            end
          end
        end
        if error
          exit 1
        end
      end

      def edit_text(text, extension)
        if (!config[:disable_editing])
          Tempfile.open([ 'ceth-edit-', extension ]) do |file|
            # Write the text to a temporary file
            file.write(text)
            file.close

            # Let the user edit the temporary file
            if !system("#{config[:editor]} #{file.path}")
              raise "Please set EDITOR environment variable"
            end

            result_text = IO.read(file.path)

            return result_text if result_text != text
          end
        end
      end
    end
  end
end

