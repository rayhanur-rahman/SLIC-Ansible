require "marketplace/reckoner/aws-sdk/metering_service"
require "net/http"
require "json"

class Marketplace
  class Reckoner
    class Updater
      class Ec2
        attr_accessor :client, :dry_run, :product_code, :usage_dimension, :free_node_count

        def initialize(opts = { dry_run: false })
          @dry_run = Marketplace::Reckoner::Config["aws"]["dry_run"] || opts[:dry_run]
          @product_code = opts[:product_code] || Marketplace::Reckoner::Config["aws"]["product_code"]
          @usage_dimension = opts[:usage_dimension] || Marketplace::Reckoner::Config["aws"]["usage_dimension"]
          @free_node_count = opts[:free_node_count] || Marketplace::Reckoner::Config["license"]["free"] || 0
          @credentails = load_credentials(opts)
          @client = Aws::MarketplaceMetering::Client.new(region: region)
        end

        def update(count)
          client.meter_usage(
            product_code: product_code,
            timestamp: Time.now.utc,
            usage_dimension: usage_dimension,
            usage_quantity: adjust_quantity(count),
            dry_run: dry_run
          )
        end

        private

        def adjust_quantity(count)
          [0, count - free_node_count].max
        end

        def region
          metadata_uri = URI("http://169.254.169.254/latest/dynamic/instance-identity/document")
          JSON.parse(Net::HTTP.get_response(metadata_uri).body)["region"] || "us-east-1"
        rescue
          "us-east-1"
        end

        def load_credentials(opts = {})
          if opts[:profile_name] || ENV["AWS_DEFAULT_PROFILE"]
            Aws::SharedCredentials.new(
              profile_name: opts[:profile_name] || ENV["AWS_DEFAULT_PROFILE"],
              path: opts[:credential_file] || File.expand_path("~/.aws/credentials")
            )
          elsif ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"]
            Aws::Credentials.new(
              ENV["AWS_ACCESS_KEY_ID"],
              ENV["AWS_SECRET_ACCESS_KEY"],
              ENV["AWS_SESSION_TOKEN"]
            )
          else
            Aws::InstanceProfileCredentials.new(retries: 1)
          end
        end
      end
    end
  end
end
