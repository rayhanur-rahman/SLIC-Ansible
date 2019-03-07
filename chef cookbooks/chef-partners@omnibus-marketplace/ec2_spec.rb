require "spec_helper"
require "marketplace/reckoner"
require "marketplace/reckoner/updater/ec2"
require "time"

describe Marketplace::Reckoner::Updater::Ec2 do
  subject(:updater) { described_class.new }

  let(:usage_meter) { double("Aws::MarketplaceMetering::Client") }
  let(:free_node_count) { 5 }
  let(:time) { Time.parse("2016-01-12 23:04:02 UTC") }
  let(:httpok) { double("Net::HTTPOK", code: 200, message: "ok", body: instance_identity) }
  let(:instance_identity) do
    '{
      "devpayProductCodes" : null,
      "privateIp" : "172.31.2.253",
      "availabilityZone" : "us-west-2b",
      "version" : "2010-08-31",
      "instanceId" : "i-5b2873d2",
      "billingProducts" : null,
      "instanceType" : "t2.large",
      "accountId" : "211051788926",
      "pendingTime" : "2016-02-04T00:01:40Z",
      "imageId" : "ami-18290f72",
      "architecture" : "x86_64",
      "kernelId" : null,
      "ramdiskId" : null,
      "region" : "us-west-2"
    }'
  end

  before do
    Marketplace::Reckoner::Config["aws"]["dry_run"] = false
    Marketplace::Reckoner::Config["aws"]["product_code"] = "MidasGutz"
    Marketplace::Reckoner::Config["aws"]["usage_dimension"] = "SeriousGutsCompetition"
    Marketplace::Reckoner::Config["updater"]["driver"] = "ec2"
    Marketplace::Reckoner::Config["license"]["free"] = free_node_count

    allow(Aws::MarketplaceMetering::Client).to receive(:new).with(region: "us-west-2").and_return(usage_meter)
    allow(Net::HTTP).to receive(:get_response).and_return(httpok)
    allow(Time).to receive(:now).and_call_original
    allow(Time).to receive(:now).and_return(time)
    allow(updater).to receive(:load_credentials).and_return(true)
  end

  describe '#update' do
    it "updates with the adjusted total" do
      expect(usage_meter).to receive(:meter_usage).with(
        product_code: "MidasGutz",
        timestamp: time,
        usage_dimension: "SeriousGutsCompetition",
        usage_quantity: 666 - free_node_count,
        dry_run: false
      )

      updater.update(666)
    end
  end
end
