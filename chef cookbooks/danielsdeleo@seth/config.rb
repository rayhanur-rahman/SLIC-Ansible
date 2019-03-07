
#
# Define config file setups for spec tests here.
# https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-context
#

# Required seth files here:
require 'seth/config'

# Required spec files here:
require 'spec_helper'

# Basic config. Nothing fancy.
shared_context "default config options" do
  before do
    Seth::Config[:cache_path] = windows? ? 'C:\seth' : '/var/seth'
  end

  # Don't need to have an after block to reset the config...
  # The spec_helper.rb takes care of resetting the config state.
end
