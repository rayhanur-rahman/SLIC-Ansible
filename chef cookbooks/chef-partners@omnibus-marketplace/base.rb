class Marketplace::Reckoner::Metrics
  class Base
    def self.data
      new.collect
    end

    def collect
      raise "A `collect` method must be defined in #{self.class}"
    end
  end
end
