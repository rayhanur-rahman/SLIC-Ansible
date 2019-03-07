require "marketplace/reckoner/config"
require "marketplace/reckoner/checker"
require "marketplace/reckoner/updater"
require "marketplace/reckoner/eetee"
require "marketplace/reckoner/machine_id"
require "marketplace/reckoner/metrics"

# The Reckoner checks node usage and updates flexible billing endpoints
class Marketplace
  class Reckoner
    def self.update_usage
      return unless Marketplace::Reckoner.enabled_in_config?
      new.update_usage
    end

    def self.enabled_in_config?
      Marketplace::Reckoner::Config.updater.enabled == true
    end

    attr_accessor :opts, :usage_checker, :usage_updater

    def initialize(opts = {})
      @opts = opts
      @usage_checker = Marketplace::Reckoner::Checker.from_opts(opts)
      @usage_updater = Marketplace::Reckoner::Updater.from_opts(opts)
    end

    def update_usage
      return unless Marketplace::Reckoner.enabled_in_config?
      usage_updater.update(usage_checker.current_usage)
    end
  end
end
