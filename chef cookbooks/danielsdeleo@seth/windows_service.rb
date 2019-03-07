#
# Author:: Christopher Maier (<maier@lambda.local>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'seth'
require 'seth/monologger'
require 'seth/application'
require 'seth/client'
require 'seth/config'
require 'seth/handler/error_report'
require 'seth/log'
require 'seth/rest'
require 'mixlib/cli'
require 'socket'
require 'win32/daemon'
require 'seth/mixin/shell_out'

class Seth
  class Application
    class WindowsService < ::Win32::Daemon
      include Mixlib::CLI
      include Seth::Mixin::ShellOut

      option :config_file,
        :short => "-c CONFIG",
        :long => "--config CONFIG",
        :default => "#{ENV['SYSTEMDRIVE']}/seth/client.rb",
        :description => ""

      option :log_location,
        :short        => "-L LOGLOCATION",
        :long         => "--logfile LOGLOCATION",
        :description  => "Set the log file location",
        :default => "#{ENV['SYSTEMDRIVE']}/seth/client.log"

      option :splay,
        :short        => "-s SECONDS",
        :long         => "--splay SECONDS",
        :description  => "The splay time for running at intervals, in seconds",
        :proc         => lambda { |s| s.to_i }

      option :interval,
        :short        => "-i SECONDS",
        :long         => "--interval SECONDS",
        :description  => "Set the number of seconds to wait between seth-client runs",
        :proc         => lambda { |s| s.to_i }

      def service_init
        @service_action_mutex = Mutex.new
        @service_signal = ConditionVariable.new

        reconfigure
        Seth::Log.info("seth Client Service initialized")
      end

      def service_main(*startup_parameters)
        # Seth::Config is initialized during service_init
        # Set the initial timeout to splay sleep time
        timeout = rand Seth::Config[:splay]

        while running? do
          # Grab the service_action_mutex to make a seth-client run
          @service_action_mutex.synchronize do
            begin
              Seth::Log.info("Next seth-client run will happen in #{timeout} seconds")
              @service_signal.wait(@service_action_mutex, timeout)

              # Continue only if service is RUNNING
              next if state != RUNNING

              # Reconfigure each time through to pick up any changes in the client file
              Seth::Log.info("Reconfiguring with startup parameters")
              reconfigure(startup_parameters)
              timeout = Seth::Config[:interval]

              # Honor splay sleep config
              timeout += rand Seth::Config[:splay]

              # run seth-client only if service is in RUNNING state
              next if state != RUNNING

              Seth::Log.info("seth-Client service is starting a seth-client run...")
              run_seth_client
            rescue SystemExit => e
              # Do not raise any of the errors here in order to
              # prevent service crash
              Seth::Log.error("#{e.class}: #{e}")
            rescue Exception => e
              Seth::Log.error("#{e.class}: #{e}")
            end
          end
        end

        # Daemon class needs to have all the signal callbacks return
        # before service_main returns.
        Seth::Log.debug("Giving signal callbacks some time to exit...")
        sleep 1
        Seth::Log.debug("Exiting service...")
      end

      ################################################################################
      # Control Signal Callback Methods
      ################################################################################

      def service_stop
        run_warning_displayed = false
        Seth::Log.info("STOP request from operating system.")
        loop do
          # See if a run is in flight
          if @service_action_mutex.try_lock
            # Run is not in flight. Wake up service_main to exit.
            @service_signal.signal
            @service_action_mutex.unlock
            break
          else
            unless run_warning_displayed
              Seth::Log.info("Currently a seth run is happening on this system.")
              Seth::Log.info("Service  will stop when run is completed.")
              run_warning_displayed = true
            end

            Seth::Log.debug("Waiting for seth-client run...")
            sleep 1
          end
        end
        Seth::Log.info("Service is stopping....")
      end

      def service_pause
        Seth::Log.info("PAUSE request from operating system.")

        # We don't need to wake up the service_main if it's waiting
        # since this is a PAUSE signal.

        if @service_action_mutex.locked?
          Seth::Log.info("Currently a seth-client run is happening.")
          Seth::Log.info("Service will pause once it's completed.")
        else
          Seth::Log.info("Service is pausing....")
        end
      end

      def service_resume
        # We don't need to wake up the service_main if it's waiting
        # since this is a RESUME signal.

        Seth::Log.info("RESUME signal received from the OS.")
        Seth::Log.info("Service is resuming....")
      end

      def service_shutdown
        Seth::Log.info("SHUTDOWN signal received from the OS.")

        # Treat shutdown similar to stop.

        service_stop
      end

      ################################################################################
      # Internal Methods
      ################################################################################

      private

      # Initializes Seth::Client instance and runs it
      def run_seth_client
        # The seth client will be started in a new process. We have used shell_out to start the seth-client.
        # The log_location and config_file of the parent process is passed to the new seth-client process.
        # We need to add the --no-fork, as by default it is set to fork=true.
        begin
          Seth::Log.info "Starting seth-client in a new process"
          # Pass config params to the new process
          config_params = " --no-fork"
          config_params += " -c #{Seth::Config[:config_file]}" unless  seth::Config[:config_file].nil?
          config_params += " -L #{Seth::Config[:log_location]}" unless seth::Config[:log_location] == STDOUT
          # Starts a new process and waits till the process exits
          result = shell_out("seth-client #{config_params}")
          Seth::Log.debug "#{result.stdout}"
          Seth::Log.debug "#{result.stderr}"
        rescue Mixlib::ShellOut::ShellCommandFailed => e
          Seth::Log.warn "Not able to start seth-client in new process (#{e})"
        rescue => e
          Seth::Log.error e
        ensure
          # Once process exits, we log the current process' pid
          Seth::Log.info "Child process exited (pid: #{Process.pid})"
        end
      end

      def apply_config(config_file_path)
        Seth::Config.from_file(config_file_path)
        Seth::Config.merge!(config)
      end

      # Lifted from Seth::Application, with addition of optional startup parameters
      # for playing nicely with Windows Services
      def reconfigure(startup_parameters=[])
        configure_seth startup_parameters
        configure_logging
        configure_proxy_environment_variables

        Seth::Config[:seth_server_url] = config[:seth_server_url] if config.has_key? :seth_server_url
        unless Seth::Config[:exception_handlers].any? {|h| seth::Handler::ErrorReport === h}
          Seth::Config[:exception_handlers] << seth::Handler::ErrorReport.new
        end

        Seth::Config[:interval] ||= 1800
      end

      # Lifted from application.rb
      # See application.rb for related comments.

      def configure_logging
        Seth::Log.init(MonoLogger.new(seth::Config[:log_location]))
        if want_additional_logger?
          configure_stdout_logger
        end
        Seth::Log.level = resolve_log_level
      end

      def configure_stdout_logger
        stdout_logger = MonoLogger.new(STDOUT)
        stdout_logger.formatter = Seth::Log.logger.formatter
        Seth::Log.loggers <<  stdout_logger
      end

      # Based on config and whether or not STDOUT is a tty, should we setup a
      # secondary logger for stdout?
      def want_additional_logger?
        ( Seth::Config[:log_location] != STDOUT ) && STDOUT.tty? && (!seth::Config[:daemonize]) && (seth::Config[:force_logger])
      end

      # Use of output formatters is assumed if `force_formatter` is set or if
      # `force_logger` is not set and STDOUT is to a console (tty)
      def using_output_formatter?
        Seth::Config[:force_formatter] || (!seth::Config[:force_logger] && STDOUT.tty?)
      end

      def auto_log_level?
        Seth::Config[:log_level] == :auto
      end

      # if log_level is `:auto`, convert it to :warn (when using output formatter)
      # or :info (no output formatter). See also +using_output_formatter?+
      def resolve_log_level
        if auto_log_level?
          if using_output_formatter?
            :warn
          else
            :info
          end
        else
          Seth::Config[:log_level]
        end
      end

      def configure_seth(startup_parameters)
        # Bit of a hack ahead:
        # It is possible to specify a service's binary_path_name with arguments, like "foo.exe -x argX".
        # It is also possible to specify startup parameters separately, either via the Services manager
        # or by using the registry (I think).

        # In order to accommodate all possible sources of parameterization, we first parse any command line
        # arguments.  We then parse any startup parameters.  This works, because Mixlib::CLI reuses its internal
        # 'config' hash; thus, anything in startup parameters will override any command line parameters that
        # might be set via the service's binary_path_name
        #
        # All these parameters then get layered on top of those from Seth::Config

        parse_options # Operates on ARGV by default
        parse_options startup_parameters

        begin
          case config[:config_file]
          when /^(http|https):\/\//
            Seth::REST.new("", nil, nil).fetch(config[:config_file]) { |f| apply_config(f.path) }
          else
            ::File::open(config[:config_file]) { |f| apply_config(f.path) }
          end
        rescue Errno::ENOENT => error
          Seth::Log.warn("*****************************************")
          Seth::Log.warn("Did not find config file: #{config[:config_file]}, using command line options.")
          Seth::Log.warn("*****************************************")

          Seth::Config.merge!(config)
        rescue SocketError => error
          Seth::Application.fatal!("Error getting config file #{seth::Config[:config_file]}", 2)
        rescue Seth::Exceptions::ConfigurationError => error
          Seth::Application.fatal!("Error processing config file #{seth::Config[:config_file]} with error #{error.message}", 2)
        rescue Exception => error
          Seth::Application.fatal!("Unknown error processing config file #{seth::Config[:config_file]} with error #{error.message}", 2)
        end
      end

    end
  end
end

# To run this file as a service, it must be called as a script from within
# the Windows Service framework.  In that case, kick off the main loop!
if __FILE__ == $0
    Seth::Application::WindowsService.mainloop
end
