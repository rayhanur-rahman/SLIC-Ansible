require 'spec_helper'

describe Seth::ceth::TagCreate do
  before(:each) do
    Seth::Config[:node_name] = "webmonkey.example.com"
    @ceth = Seth::ceth::TagCreate.new
    @ceth.name_args = [ Seth::Config[:node_name], "happytag" ]

    @node = Seth::Node.new
    @node.stub :save
    Seth::Node.stub(:load).and_return @node
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "can create tags on a node" do
      @ceth.run
      @node.tags.should == ["happytag"]
      @stdout.string.should match /created tags happytag.+node webmonkey.example.com/i
    end
  end
end
