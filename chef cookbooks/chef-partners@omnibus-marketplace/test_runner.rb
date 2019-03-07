# frozen_string_literal: true
require "parallel"
require "ruby-progressbar"
require "time"
require "fileutils"
require "zip"

module Template
  class TestRunner
    class << self
      def run(scenarios)
        new(scenarios).run
      end
    end

    attr_accessor :scenarios

    def initialize(scenarios = [])
      @scenarios = scenarios
    end

    def run
      Parallel.each(
        scenarios,
        isolation: true,
        progress: "Running Scenarios",
        in_threads: 4
      ) do |scenario|
        begin
          scenario.setup_command.run_command
          scenario.command.run_command
          scenario.log_command.run_command
          scenario.delete_command.run_command
        rescue Mixlib::ShellOut::CommandTimeout => e
          raise e unless scenario.retry?
          scenario.retry
        end
      end

      zipfile_name = File.join(Dir.pwd, "#{Time.now.iso8601}-results.zip")
      puts "Writing log archive to #{zipfile_name}"
      Zip::OutputStream.open(zipfile_name) do |zipfile|
        scenarios.each do |scenario|
          zipfile.put_next_entry("#{scenario.name}.txt")
          zipfile.write(scenario.log_command.stdout)
        end
      end

      report_errors
    end

    def report_errors
      scenarios.each do |scenario|
        if scenario.setup_command.exitstatus && scenario.setup_command.exitstatus.to_s != "0"
          puts "ERROR: #{scenario.name} failed with: #{scenario.setup_command.stderr}"
        end
        if scenario.command.exitstatus && scenario.command.exitstatus.to_s != "0"
          puts "ERROR: #{scenario.name} failed with: #{scenario.command.stderr}"
        end
      end
    end
  end
end
