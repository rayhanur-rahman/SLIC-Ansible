require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::ChefUserCount do
  it_behaves_like "a standard metric collector"

  let(:metric) { described_class.new }
  describe '#collect' do
    let(:checker) { double("checker") }

    it "returns data from the ChefServer checker" do
      expect(Marketplace::Reckoner::Checker::ChefServer).to receive(:new).and_return(checker)
      expect(checker).to receive(:user_count).and_return(123)
      expect(metric.collect).to eq(123)
    end
  end
end
