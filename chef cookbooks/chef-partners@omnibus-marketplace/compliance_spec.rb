require "spec_helper"
require "marketplace/reckoner"
require "marketplace/reckoner/checker/compliance"

describe Marketplace::Reckoner::Checker::Compliance do
  subject { described_class.new }

  let(:node_license) { 55 }
  let(:node_count) { 15 }
  let(:node_limit_exceeded) { false }
  let(:db) { double("Sequel") }

  before do
    Marketplace::Reckoner::Config["checker"]["driver"] = "compliance"
    Marketplace::Reckoner::Config["license"]["count"] = node_license
    allow(Sequel).to receive(:postgres).and_return(db)
    allow(db).to receive(:from).with("nodes").and_return((0...node_count))
  end

  describe '#current_usage' do
    it "retrieves current usage from the chef server" do
      expect(subject.current_usage).to eq(node_count)
    end
  end

  describe '#max_nodes' do
    it "retrieves the license count from the chef server" do
      expect(subject.max_nodes).to eq(node_license)
    end
  end

  describe '#limit_exceeded?' do
    it "determines if the limit is exceeded" do
      expect(subject.limit_exceeded?).to eq(node_limit_exceeded)
    end
  end
end
