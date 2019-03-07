require "sequel"

class Marketplace
  class Reckoner
    class Checker
      class Compliance
        attr_accessor :db, :max_nodes

        def initialize(opts = {})
          init(opts)
        end

        def current_usage
          db.from("nodes").count
        end

        def limit_exceeded?
          max_nodes - current_usage <= 0
        end

        def reset!
          @db = nil
          @max_nodes = nil
          init
        end

        private

        def init(opts = {})
          @db = Sequel.postgres(
            "chef_compliance",
            host: opts[:host] || Marketplace::Reckoner::Config["db"]["host"],
            port: opts[:port] || Marketplace::Reckoner::Config["db"]["port"],
            user: opts[:user] || Marketplace::Reckoner::Config["db"]["user"],
            password: opts[:password] || Marketplace::Reckoner::Config["db"]["password"]
          )
          @max_nodes = opts[:license_count] || Marketplace::Reckoner::Config["license"]["count"]
        end
      end
    end
  end
end
