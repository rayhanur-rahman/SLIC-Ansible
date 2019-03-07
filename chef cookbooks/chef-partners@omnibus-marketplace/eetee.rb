require "json"
require "net/http"
require "securerandom"
require "marketplace/reckoner/machine_id"

class Marketplace
  class Reckoner
    class Eetee
      include Marketplace::Reckoner::MachineID

      attr_reader :metrics_to_collect, :run_period
      attr_accessor :payload

      VERSION = "1".freeze

      def self.daily_runner
        metrics_to_collect = Marketplace::Reckoner::Config.phone_home.metrics.daily
        return if metrics_to_collect.nil? || metrics_to_collect.empty?

        runner = new(metrics_to_collect)
        return if runner.disabled? || runner.endpoint.nil? || runner.endpoint.empty?

        runner.run
      end

      def self.enabled_in_config?
        Marketplace::Reckoner::Config.phone_home.enabled == true
      end

      def initialize(metrics_to_collect)
        @run_period = run_period
        @metrics_to_collect = metrics_to_collect

        @payload = { "metrics" => {} }
      end

      def run
        collect_metrics
        send_metrics
      end

      def collect_metrics
        payload["eetee_version"] = VERSION
        payload["machine_uuid"]  = machine_uuid
        payload["platform"]      = Marketplace::Reckoner::Config.phone_home.platform
        payload["time_started"]  = Time.now

        metrics_to_collect.each do |metric|
          metric_data = Marketplace::Reckoner::Metrics.class_for(metric).data
          payload["metrics"][metric] = metric_data unless metric_data.nil?
        end

        payload["time_finished"] = Time.now

        payload
      end

      def send_metrics
        uri = URI(endpoint)
        request = Net::HTTP::Post.new(uri)
        request.body = payload.to_json
        request.content_type = "application/json"

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.request(request)
        end
      end

      def endpoint
        Marketplace::Reckoner::Config.phone_home.endpoint
      end

      def disabled?
        stop_file_exists? || !enabled_in_config?
      end

      def stop_file_exists?
        File.exist?("/etc/opscode/DISABLE_PHONE_HOME")
      end

      def enabled_in_config?
        Marketplace::Reckoner::Eetee.enabled_in_config?
      end
    end
  end
end
