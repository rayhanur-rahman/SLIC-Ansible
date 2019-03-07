#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Seth::ceth::NodeBulkDelete do
  before(:each) do
    Seth::Log.logger = Logger.new(StringIO.new)

    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeBulkDelete.new
    @ceth.name_args = ["."]
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
    @ceth.ui.stub(:confirm).and_return(true)
    @nodes = Hash.new
    %w{adam brent jacob}.each do |node_name|
      @nodes[node_name] = "http://localhost:4000/nodes/#{node_name}"
    end
  end

  describe "when creating the list of nodes" do
    it "fetches the node list" do
      expected = @nodes.inject({}) do |inflatedish, (name, uri)|
        inflatedish[name] = Seth::Node.new.tap {|n| n.name(name)}
        inflatedish
      end
      Seth::Node.should_receive(:list).and_return(@nodes)
      # I hate not having == defined for anything :(
      actual = @ceth.all_nodes
      actual.keys.should =~ expected.keys
      actual.values.map {|n| n.name }.should =~ %w[adam brent jacob]
    end
  end

  describe "run" do
    before do
      @inflatedish_list = @nodes.keys.inject({}) do |nodes_by_name, name|
        node = Seth::Node.new()
        node.name(name)
        node.stub(:destroy).and_return(true)
        nodes_by_name[name] = node
        nodes_by_name
      end
      @ceth.stub(:all_nodes).and_return(@inflatedish_list)
    end

    it "should print the nodes you are about to delete" do
      @ceth.run
      @stdout.string.should match(/#{@ceth.ui.list(@nodes.keys.sort, :columns_down)}/)
    end

    it "should confirm you really want to delete them" do
      @ceth.ui.should_receive(:confirm)
      @ceth.run
    end

    it "should delete each node" do
      @inflatedish_list.each_value do |n|
        n.should_receive(:destroy)
      end
      @ceth.run
    end

    it "should only delete nodes that match the regex" do
      @ceth.name_args = ['adam']
      @inflatedish_list['adam'].should_receive(:destroy)
      @inflatedish_list['brent'].should_not_receive(:destroy)
      @inflatedish_list['jacob'].should_not_receive(:destroy)
      @ceth.run
    end

    it "should exit if the regex is not provided" do
      @ceth.name_args = []
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

  end
end



