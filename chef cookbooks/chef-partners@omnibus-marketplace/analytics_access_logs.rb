require "marketplace/reckoner/metrics/log_parser"

class Marketplace::Reckoner::Metrics
  class AnalyticsAccessLogs < LogParser
    def filenames
      "/var/log/opscode/nginx/analytics.access.log*"
    end

    def metric_matchers
      { log_count: proc { |line| !line.empty? } }
    end
  end
end
