require "marketplace/reckoner/metrics/analytics_access_logs"
require "marketplace/reckoner/metrics/base"
require "marketplace/reckoner/metrics/chef_node_count"
require "marketplace/reckoner/metrics/chef_nodes_per_org"
require "marketplace/reckoner/metrics/chef_org_count"
require "marketplace/reckoner/metrics/chef_user_count"
require "marketplace/reckoner/metrics/erchef_crashes"
require "marketplace/reckoner/metrics/manage_access_logs"

class Marketplace
  class Reckoner
    class Metrics
      def self.class_for(metric)
        const_get(metric.split("_").map(&:capitalize).join)
      end
    end
  end
end
