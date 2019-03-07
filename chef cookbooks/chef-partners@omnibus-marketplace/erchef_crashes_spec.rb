require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::ErchefCrashes do
  it_behaves_like "a logparser metric collector"

  let(:parser) { described_class.new }

  describe '#metric_matchers' do
    describe "log_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:log_count]
        expect(metric_matcher.call("this should not match")).to be_falsey
        expect(metric_matcher.call("CRASH REPORT should match")).to be_truthy
        expect(metric_matcher.call("this ERROR REPORT should match")).to be_truthy
        expect(metric_matcher.call("this INFO REPORT should not match")).to be_falsey
      end
    end
  end
end
