require "spec_helper"
require "marketplace/reckoner"
require "marketplace/reckoner/checker/chef_server"

describe Marketplace::Reckoner::Checker::ChefServer do
  subject { described_class.new }

  let(:server_api) { double("Chef::ServerAPI") }
  let(:license) do
    { "node_count" => node_count,
      "node_license" => node_license,
      "limit_exceeded" => node_limit_exceeded
    }
  end
  let(:node_count) { 12 }
  let(:node_license) { 25 }
  let(:node_limit_exceeded) { false }

  before do
    Marketplace::Reckoner::Config["checker"]["driver"] = "chef_server"
    allow(Chef::ServerAPI).to receive(:new).and_return(server_api)
    allow(server_api).to receive(:get).with("license").and_return(license)
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
