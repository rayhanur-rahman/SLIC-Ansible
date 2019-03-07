require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::ChefNodesPerOrg do
  it_behaves_like "a standard metric collector"

  let(:metric) { described_class.new }
  describe '#collect' do
    let(:checker) { double("checker") }
    let(:orgs)    { %w{org1 org2 org3} }

    it "returns data from the ChefServer checker" do
      expect(Marketplace::Reckoner::Checker::ChefServer).to receive(:new).and_return(checker)
      expect(checker).to receive(:orgs).and_return(%w{org1 org2 org3})
      expect(checker).to receive(:org_node_count).with("org1").and_return(1)
      expect(checker).to receive(:org_node_count).with("org2").and_return(2)
      expect(checker).to receive(:org_node_count).with("org3").and_return(3)
      expect(metric).to receive(:salted_org_name).with("org1").and_return("saltorg1")
      expect(metric).to receive(:salted_org_name).with("org2").and_return("saltorg2")
      expect(metric).to receive(:salted_org_name).with("org3").and_return("saltorg3")

      data = metric.collect
      expect(data["saltorg1"]).to eq(1)
      expect(data["saltorg2"]).to eq(2)
      expect(data["saltorg3"]).to eq(3)
    end
  end
end
