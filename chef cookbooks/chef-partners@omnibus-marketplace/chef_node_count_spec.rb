require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::ChefNodeCount do
  it_behaves_like "a standard metric collector"

  let(:metric) { described_class.new }
  describe '#collect' do
    let(:checker) { double("checker") }

    it "returns data from the ChefServer checker" do
      expect(Marketplace::Reckoner::Checker::ChefServer).to receive(:new).and_return(checker)
      expect(checker).to receive(:current_usage).and_return(123)
      expect(checker).to receive(:max_nodes).and_return(321)

      data = metric.collect
      expect(data["node_count"]).to eq(123)
      expect(data["license_count"]).to eq(321)
    end
  end
end
