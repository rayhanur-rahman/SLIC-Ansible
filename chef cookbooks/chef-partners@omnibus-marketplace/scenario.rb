# frozen_string_literal: true
require "mixlib/shellout"

module Template
  class Scenario
    attr_accessor :name, :command, :delete_command, :log_command, :setup_command
    attr_accessor :retry_command, :retries

    def initialize(name:, command:, delete_command:, log_command:, setup_command:,
                  retry_command:, retries: 0, max_retries: 2)
      @name = name
      @command = Mixlib::ShellOut.new(command, timeout: 3600)
      @setup_command = Mixlib::ShellOut.new(setup_command)
      @delete_command = Mixlib::ShellOut.new(delete_command)
      @log_command = Mixlib::ShellOut.new(log_command)
      @retry_command = Mixlib::ShellOut.new(retry_command)
      @retries = retries
      @max_retries = max_retries
    end

    def retry?
      retries < max_retries
    end

    def retry
      retries += 1
      retry_command.run_command
      command.run_command
    end
  end
end
