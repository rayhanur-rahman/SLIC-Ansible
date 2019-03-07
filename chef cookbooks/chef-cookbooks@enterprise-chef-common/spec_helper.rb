require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.log_level = :error # Avoid deprecation notice SPAM
end
