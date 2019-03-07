require 'spec_helper'

describe Seth::ceth::TagList do
  before(:each) do
    Seth::Config[:node_name] = "webmonkey.example.com"
    @ceth = Seth::ceth::TagList.new
    @ceth.name_args = [ Seth::Config[:node_name], "sadtag" ]

    @node = Seth::Node.new
    @node.stub :save
    @node.tags << "sadtag" << "happytag"
    Seth::Node.stub(:load).and_return @node
  end

  describe "run" do
    it "can list tags on a node" do
      expected = %w(sadtag happytag)
      @node.tags.should == expected
      @ceth.should_receive(:output).with(expected)
      @ceth.run
    end
  end
end
