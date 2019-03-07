require "marketplace/reckoner/metrics/log_parser"

class Marketplace::Reckoner::Metrics
  class ManageAccessLogs < LogParser
    def filenames
      "/var/log/opscode/nginx/access.log*"
    end

    def metric_matchers
      {
        client_count: proc { |line| line.include?("Chef Client") },
        knife_count: proc  { |line| line.include?("Chef Knife") },
        browser_count: proc { |line| line !~ /Chef (Client|Knife)/ && !line.empty? },
        reporting_count: proc { |line| line =~ %r{/organizations/\S+/reports/} }
      }
    end
  end
end
