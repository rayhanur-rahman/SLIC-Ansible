require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Eetee do
  let(:metrics_to_collect) { %w{erchef_crashes chef_node_count} }
  let(:eetee)              { described_class.new(metrics_to_collect) }

  describe '#collect_metrics' do
    let(:machine_uuid) { "machine_uuid_1" }
    let(:phone_home_config) { double("phone_home_config") }
    let(:platform)          { "my_platform" }
    let(:start_time)        { "time_started" }
    let(:end_time)          { "time_ended" }
    let(:erchef_data)       { "erchef_test_data" }
    let(:node_count_data)   { "node_count_test_data" }

    it "returns a payload containing expected data" do
      expect(eetee).to receive(:machine_uuid).and_return(machine_uuid)
      expect(Marketplace::Reckoner::Config).to receive(:phone_home).and_return(phone_home_config)
      expect(phone_home_config).to receive(:platform).and_return(platform)
      expect(Marketplace::Reckoner::Metrics::ErchefCrashes).to receive(:data).and_return(erchef_data)
      expect(Marketplace::Reckoner::Metrics::ChefNodeCount).to receive(:data).and_return(node_count_data)
      expect(Time).to receive(:now).twice.and_return(start_time, end_time)

      payload = eetee.collect_metrics

      expect(payload["eetee_version"]).to eq(Marketplace::Reckoner::Eetee::VERSION)
      expect(payload["machine_uuid"]).to eq(machine_uuid)
      expect(payload["platform"]).to eq(platform)
      expect(payload["time_started"]).to eq(start_time)
      expect(payload["time_finished"]).to eq(end_time)
      expect(payload["metrics"]["chef_node_count"]).to eq(node_count_data)
      expect(payload["metrics"]["erchef_crashes"]).to eq(erchef_data)
    end
  end

  describe '#disabled?' do
    context "when the stop file does not exist" do
      before do
        allow(eetee).to receive(:stop_file_exists?).and_return(false)
      end

      context "when eetee is enabled in the config" do
        it "returns false" do
          allow(eetee).to receive(:enabled_in_config?).and_return(true)
          expect(eetee.disabled?).to eq(false)
        end
      end

      context "when eetee is disabled in the config" do
        it "returns true" do
          allow(eetee).to receive(:enabled_in_config?).and_return(false)
          expect(eetee.disabled?).to eq(true)
        end
      end
    end

    context "when the stop file exists" do
      it "returns true" do
        allow(eetee).to receive(:stop_file_exists?).and_return(true)
        expect(eetee.disabled?).to eq(true)
      end
    end
  end
end
