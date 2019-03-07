#--
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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
require 'seth/client'
require 'forwardable'

class Seth
  # == Seth::Handler
  # The base class for an Exception or Notification Handler. Create your own
  # handler by subclassing Seth::Handler. When a seth run fails with an
  # uncaught Exception, Seth will set the +run_status+ on your handler and call
  # +report+
  #
  # ===Example:
  #
  #   require 'net/smtp'
  #
  #   module MyOrg
  #     class OhNoes < Seth::Handler
  #
  #       def report
  #         # Create the email message
  #         message  = "From: Your Name <your@mail.address>\n"
  #         message << "To: Destination Address <someone@example.com>\n"
  #         message << "Subject: Seth Run Failure\n"
  #         message << "Date: #{Time.now.rfc2822}\n\n"
  #
  #         # The Node is available as +node+
  #         message << "Seth run failed on #{node.name}\n"
  #         # +run_status+ is a value object with all of the run status data
  #         message << "#{run_status.formatted_exception}\n"
  #         # Join the backtrace lines. Coerce to an array just in case.
  #         message << Array(backtrace).join("\n")
  #
  #         # Send the email
  #         Net::SMTP.start('your.smtp.server', 25) do |smtp|
  #           smtp.send_message message, 'from@address', 'to@address'
  #         end
  #       end
  #
  #     end
  #   end
  #
  class Handler

    # The list of currently configured start handlers
    def self.start_handlers
      Array(Seth::Config[:start_handlers])
    end

    # Run the start handlers. This will usually be called by a notification
    # from Seth::Client
    def self.run_start_handlers(run_status)
      Seth::Log.info("Running start handlers")
      start_handlers.each do |handler|
        handler.run_report_safely(run_status)
      end
      Seth::Log.info("Start handlers complete.")
    end

    # Wire up a notification to run the start handlers when the seth run
    # starts.
    Seth::Client.when_run_starts do |run_status|
      run_start_handlers(run_status)
    end

    # The list of currently configured report handlers
    def self.report_handlers
      Array(Seth::Config[:report_handlers])
    end

    # Run the report handlers. This will usually be called by a notification
    # from Seth::Client
    def self.run_report_handlers(run_status)
      events = run_status.events
      events.handlers_start(report_handlers.size)
      Seth::Log.info("Running report handlers")
      report_handlers.each do |handler|
        handler.run_report_safely(run_status)
        events.handler_executed(handler)
      end
      events.handlers_completed
      Seth::Log.info("Report handlers complete")
    end

    # Wire up a notification to run the report handlers if the seth run
    # succeeds.
    Seth::Client.when_run_completes_successfully do |run_status|
      run_report_handlers(run_status)
    end

    # The list of currently configured exception handlers
    def self.exception_handlers
      Array(Seth::Config[:exception_handlers])
    end

    # Run the exception handlers. Usually will be called by a notification
    # from Seth::Client when the run fails.
    def self.run_exception_handlers(run_status)
      events = run_status.events
      events.handlers_start(exception_handlers.size)
      Seth::Log.error("Running exception handlers")
      exception_handlers.each do |handler|
        handler.run_report_safely(run_status)
        events.handler_executed(handler)
      end
      events.handlers_completed
      Seth::Log.error("Exception handlers complete")
    end

    # Wire up a notification to run the exception handlers if the seth run fails.
    Seth::Client.when_run_fails do |run_status|
      run_exception_handlers(run_status)
    end

    extend Forwardable

    # The Seth::RunStatus object containing data about the seth run.
    attr_reader :run_status

    ##
    # :method: start_time
    #
    # The time the seth run started
    def_delegator :@run_status, :start_time

    ##
    # :method: end_time
    #
    # The time the seth run ended
    def_delegator :@run_status, :end_time

    ##
    # :method: elapsed_time
    #
    # The time elapsed between the start and finish of the seth run
    def_delegator :@run_status, :elapsed_time

    ##
    # :method: run_context
    #
    # The Seth::RunContext object used by the seth run
    def_delegator :@run_status, :run_context

    ##
    # :method: exception
    #
    # The uncaught Exception that terminated the seth run, or nil if the run
    # completed successfully
    def_delegator :@run_status, :exception

    ##
    # :method: backtrace
    #
    # The backtrace captured by the uncaught exception that terminated the seth
    # run, or nil if the run completed successfully
    def_delegator :@run_status, :backtrace

    ##
    # :method: node
    #
    # The Seth::Node for this client run
    def_delegator :@run_status, :node

    ##
    # :method: all_resources
    #
    # An Array containing all resources in the seth run's resource_collection
    def_delegator :@run_status, :all_resources

    ##
    # :method: updated_resources
    #
    # An Array containing all resources that were updated during the seth run
    def_delegator :@run_status, :updated_resources

    ##
    # :method: success?
    #
    # Was the seth run successful? True if the seth run did not raise an
    # uncaught exception
    def_delegator :@run_status, :success?

    ##
    # :method: failed?
    #
    # Did the seth run fail? True if the seth run raised an uncaught exception
    def_delegator :@run_status, :failed?

    # The main entry point for report handling. Subclasses should override this
    # method with their own report handling logic.
    def report
    end

    # Runs the report handler, rescuing and logging any errors it may cause.
    # This ensures that all handlers get a chance to run even if one fails.
    # This method should not be overridden by subclasses unless you know what
    # you're doing.
    def run_report_safely(run_status)
      run_report_unsafe(run_status)
    rescue Exception => e
      Seth::Log.error("Report handler #{self.class.name} raised #{e.inspect}")
      Array(e.backtrace).each { |line| Seth::Log.error(line) }
    ensure
      @run_status = nil
    end

    # Runs the report handler without any error handling. This method should
    # not be used directly except in testing.
    def run_report_unsafe(run_status)
      @run_status = run_status
      report
    end

    # Return the Hash representation of the run_status
    def data
      @run_status.to_hash
    end

  end
end
