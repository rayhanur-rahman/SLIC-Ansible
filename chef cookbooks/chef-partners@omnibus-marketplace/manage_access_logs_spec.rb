require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::ManageAccessLogs do
  it_behaves_like "a logparser metric collector"

  let(:parser) { described_class.new }

  describe '#metric_matchers' do
    describe "client_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:client_count]
        expect(metric_matcher.call("Chef Client should match")).to be_truthy
        expect(metric_matcher.call("Chef Knife should not match")).to be_falsey
        expect(metric_matcher.call("blah blah should not match")).to be_falsey
        expect(metric_matcher.call("")).to be_falsey
      end
    end

    describe "knife_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:knife_count]
        expect(metric_matcher.call("Chef Knife should match")).to be_truthy
        expect(metric_matcher.call("Chef Client should not match")).to be_falsey
        expect(metric_matcher.call("blah blah should not match")).to be_falsey
        expect(metric_matcher.call("")).to be_falsey
      end
    end

    describe "browser_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:browser_count]
        expect(metric_matcher.call("Chef Knife should not match")).to be_falsey
        expect(metric_matcher.call("Chef Client should not match")).to be_falsey
        expect(metric_matcher.call("blah blah should match")).to be_truthy
        expect(metric_matcher.call("")).to be_falsey
      end
    end

    describe "reporting_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:reporting_count]
        expect(metric_matcher.call("Chef Knife should not match")).to be_falsey
        expect(metric_matcher.call("Chef Client should not match")).to be_falsey
        expect(metric_matcher.call("blah blah should not match")).to be_falsey
        expect(metric_matcher.call("blah blah /organizations/myorg/reports/ blah")).to be_truthy
        expect(metric_matcher.call("")).to be_falsey
      end
    end
  end
end
