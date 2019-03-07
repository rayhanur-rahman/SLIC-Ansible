class Marketplace
  class Reckoner
    class Updater
      autoload :Ec2, "marketplace/reckoner/updater/ec2"

      def self.from_opts(opts)
        driver = opts.delete(:updater) || Marketplace::Reckoner::Config["updater"]["driver"]
        const_get(driver.split("_").map(&:capitalize).join).new
      end
    end
  end
end
