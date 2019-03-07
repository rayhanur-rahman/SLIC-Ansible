require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::Base do
  it_behaves_like "a standard metric collector"

  describe '#collect' do
    it "raises an exception" do
      expect { described_class.new.collect }.to raise_error(RuntimeError)
    end
  end
end
