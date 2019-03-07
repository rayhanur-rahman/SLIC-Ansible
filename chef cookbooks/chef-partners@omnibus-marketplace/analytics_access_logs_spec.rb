require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::AnalyticsAccessLogs do
  it_behaves_like "a logparser metric collector"

  let(:parser) { described_class.new }

  describe '#metric_matchers' do
    describe "log_count" do
      it "matches metrics correctly" do
        metric_matcher = parser.metric_matchers[:log_count]
        expect(metric_matcher.call("this should match")).to eq(true)
        expect(metric_matcher.call("")).to eq(false)
      end
    end
  end
end
