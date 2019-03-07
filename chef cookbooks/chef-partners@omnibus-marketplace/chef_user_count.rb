require "marketplace/reckoner/metrics/base"
require "marketplace/reckoner/checker/chef_server"

class Marketplace::Reckoner::Metrics
  class ChefUserCount < Base
    def collect
      checker = Marketplace::Reckoner::Checker::ChefServer.new
      checker.user_count
    end
  end
end
