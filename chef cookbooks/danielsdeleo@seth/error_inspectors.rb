require 'seth/formatters/error_inspectors/node_load_error_inspector'
require "seth/formatters/error_inspectors/registration_error_inspector"
require 'seth/formatters/error_inspectors/compile_error_inspector'
require 'seth/formatters/error_inspectors/resource_failure_inspector'
require 'seth/formatters/error_inspectors/run_list_expansion_error_inspector'
require 'seth/formatters/error_inspectors/cookbook_resolve_error_inspector'
require "seth/formatters/error_inspectors/cookbook_sync_error_inspector"

class Seth
  module Formatters

    # == ErrorInspectors
    # Error inspectors wrap exceptions and contextual information. They
    # generate diagnostic messages about possible causes of the error for user
    # consumption.
    module ErrorInspectors
    end
  end
end
