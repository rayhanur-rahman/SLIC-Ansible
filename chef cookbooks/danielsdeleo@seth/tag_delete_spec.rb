require 'spec_helper'

describe Seth::ceth::TagDelete do
  before(:each) do
    Seth::Config[:node_name] = "webmonkey.example.com"
    @ceth = Seth::ceth::TagDelete.new
    @ceth.name_args = [ Seth::Config[:node_name], "sadtag" ]

    @node = Seth::Node.new
    @node.stub :save
    @node.tags << "sadtag" << "happytag"
    Seth::Node.stub(:load).and_return @node
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "can delete tags on a node" do
      @node.tags.should == ["sadtag", "happytag"]
      @ceth.run
      @node.tags.should == ["happytag"]
      @stdout.string.should match /deleted.+sadtag/i
    end
  end
end
