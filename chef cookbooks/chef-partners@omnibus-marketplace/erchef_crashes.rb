require "marketplace/reckoner/metrics/base"

class Marketplace::Reckoner::Metrics
  class ErchefCrashes < LogParser
    def filenames
      "/var/log/opscode/opscode-erchef/crash.log*"
    end

    def metric_matchers
      { log_count: proc { |line| line =~ /(CRASH|ERROR) REPORT/ } }
    end
  end
end
