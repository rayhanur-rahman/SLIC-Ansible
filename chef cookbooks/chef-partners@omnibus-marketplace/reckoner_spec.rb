require "spec_helper"
require "marketplace/reckoner"
require "marketplace/reckoner/updater/ec2"
require "marketplace/reckoner/checker/chef_server"

describe Marketplace::Reckoner do
  subject { described_class.new }

  let(:updater) { double("Updater", update: true) }
  let(:checker) { double("Checker", current_usage: 666) }

  before do
    Marketplace::Reckoner::Config["checker"]["driver"] = "chef_server"
    Marketplace::Reckoner::Config["updater"]["driver"] = "ec2"

    allow(Marketplace::Reckoner::Checker::ChefServer).to receive(:new).and_return(checker)
    allow(Marketplace::Reckoner::Updater::Ec2).to receive(:new).and_return(updater)
    allow(Marketplace::Reckoner).to receive(:enabled_in_config?).and_return(true)
  end

  describe '#self.update_usage' do
    context "when the updater is enabled" do
      it "builds an instance and updates usage" do
        expect(updater).to receive(:update).with(666)
        Marketplace::Reckoner.update_usage
      end
    end

    context "when the updater is disabled" do
      it "does not update any usage" do
        allow(Marketplace::Reckoner).to receive(:enabled_in_config?).and_return(false)
        expect(updater).not_to receive(:update)
      end
    end
  end

  describe '#update_usage' do
    context "when the updater is enabled" do
      it "checks usage and updates the usage" do
        expect(updater).to receive(:update).with(666)
        subject.update_usage
      end
    end

    context "when the updater is disabled" do
      it "does not update any usage" do
        allow(Marketplace::Reckoner).to receive(:enabled_in_config?).and_return(false)
        expect(updater).not_to receive(:update)
      end
    end
  end
end
