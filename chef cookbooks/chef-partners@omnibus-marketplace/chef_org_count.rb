require "marketplace/reckoner/metrics/base"
require "marketplace/reckoner/checker/chef_server"

class Marketplace::Reckoner::Metrics
  class ChefOrgCount < Base
    def collect
      checker = Marketplace::Reckoner::Checker::ChefServer.new
      checker.org_count
    end
  end
end
