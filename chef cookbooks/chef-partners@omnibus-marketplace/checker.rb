class Marketplace
  class Reckoner
    class Checker
      autoload :ChefServer, "marketplace/reckoner/checker/chef_server"
      autoload :Compliance, "marketplace/reckoner/checker/compliance"
      autoload :Automate,   "marketplace/reckoner/checker/automate"

      def self.from_opts(opts)
        driver = opts.delete(:checker) || Marketplace::Reckoner::Config["checker"]["driver"]
        const_get(driver.split("_").map(&:capitalize).join).new
      end
    end
  end
end
