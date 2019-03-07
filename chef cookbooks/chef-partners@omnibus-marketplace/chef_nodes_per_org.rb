require "digest"
require "marketplace/reckoner/metrics/base"
require "marketplace/reckoner/checker/chef_server"
require "marketplace/reckoner/machine_id"

class Marketplace::Reckoner::Metrics
  class ChefNodesPerOrg < Base
    include Marketplace::Reckoner::MachineID

    def collect
      checker = Marketplace::Reckoner::Checker::ChefServer.new

      checker.orgs.each_with_object({}) do |(org, _org_url), memo|
        memo[salted_org_name(org)] = checker.org_node_count(org)
      end
    end

    def salted_org_name(org_name)
      Digest::SHA1.hexdigest(machine_salt + org_name)
    end
  end
end
