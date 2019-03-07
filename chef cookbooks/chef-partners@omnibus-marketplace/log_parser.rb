require "marketplace/reckoner/metrics/base"

class Marketplace::Reckoner::Metrics
  class LogParser < Base
    attr_accessor :counts
    def initialize
      super

      @counts = metric_matchers.keys.each_with_object({}) do |metric, memo|
        memo[metric] = 0
      end
    end

    def collect
      Array(filenames).each do |file_pattern|
        files = files_to_parse(file_pattern)

        next if files.empty?

        seek = seek_for(file_pattern)

        if files.size == 1
          # no logs have rolled, so we'll read from our marker
          # and update the marker
          update_marker_for(file_pattern, parse_file(files.first, seek))
        else
          # logs have rolled, so we'll use the marker for the oldest file
          parse_file(files.pop, seek)

          # we'll parse the newest file and update our marker
          update_marker_for(file_pattern, parse_file(files.shift, 0))

          # and we'll parse the remaining files completely
          files.each { |file| parse_file(file, 0) }
        end
      end

      counts
    end

    def filenames
      raise "No filenames defined in #{self.class}."
    end

    def metric_matchers
      raise "No metric_matchers defined in #{self.class}."
    end

    def parser_class
      self.class.to_s
    end

    def marker_file
      "/var/opt/chef-marketplace/reckoner/etc/file_markers.json"
    end

    def file_markers
      return {} unless File.exist?(marker_file)

      JSON.load(File.read(marker_file))
    end

    def marker_for(filename)
      markers = file_markers
      return {} unless markers.key?(parser_class)

      markers[parser_class][filename]
    end

    def seek_for(filename)
      seek = marker_for(filename)["seek"]
      seek.nil? ? 0 : seek
    end

    def last_parse_time_for(filename)
      time = marker_for(filename)["last_parse_time"]
      time.nil? ? Time.at(0) : Time.at(time)
    end

    def update_marker_for(filename, seek)
      markers = file_markers

      markers[parser_class] = {} unless markers.key?(parser_class)
      markers[parser_class][filename] = {} unless markers[parser_class].key?(filename)
      markers[parser_class][filename]["seek"] = seek
      markers[parser_class][filename]["last_parse_time"] = Time.now.to_i

      File.write(marker_file, JSON.pretty_generate(markers))
    end

    def files_to_parse(file_pattern)
      last_parse_time = last_parse_time_for(file_pattern)

      files = Dir.glob(file_pattern).each_with_object([]) do |file, memo|
        memo << file if File.mtime(file) > last_parse_time
      end

      files.sort { |a, b| File.mtime(b) <=> File.mtime(a) }
    end

    def parse_file(filename, seek)
      return unless File.exist?(filename)

      File.open(filename, "r") do |file|
        file.seek(seek) unless seek > file.size

        until file.eof?
          line = file.readline.strip
          metric_matchers.each do |metric, block|
            counts[metric] += 1 if block.call(line)
          end
        end
      end

      File.size(filename)
    end
  end
end
