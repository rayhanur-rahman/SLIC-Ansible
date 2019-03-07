require "marketplace/reckoner/metrics/base"
require "marketplace/reckoner/checker/chef_server"

class Marketplace::Reckoner::Metrics
  class ChefNodeCount < Base
    def collect
      checker = Marketplace::Reckoner::Checker::ChefServer.new
      {
        "node_count" => checker.current_usage,
        "license_count" => checker.max_nodes
      }
    end
  end
end
