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

describe Seth::ceth::NodeRunListRemove do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeRunListRemove.new
    @ceth.config[:print_after] = nil
    @ceth.name_args = [ "adam", "role[monkey]" ]
    @node = Seth::Node.new()
    @node.name("cethtest-node")
    @node.run_list << "role[monkey]"
    @node.stub(:save).and_return(true)

    @ceth.ui.stub(:output).and_return(true)
    @ceth.ui.stub(:confirm).and_return(true)

    Seth::Node.stub(:load).and_return(@node)
  end

  describe "run" do
    it "should load the node" do
      Seth::Node.should_receive(:load).with("adam").and_return(@node)
      @ceth.run
    end

    it "should remove the item from the run list" do
      @ceth.run
      @node.run_list[0].should_not == 'role[monkey]'
    end

    it "should save the node" do
      @node.should_receive(:save).and_return(true)
      @ceth.run
    end

    it "should print the run list" do
      @ceth.config[:print_after] = true
      @ceth.ui.should_receive(:output).with({ "cethtest-node" => { 'run_list' => [] } })
      @ceth.run
    end

    describe "run with a list of roles and recipes" do
      it "should remove the items from the run list" do
        @node.run_list << 'role[monkey]'
        @node.run_list << 'recipe[duck::type]'
        @ceth.name_args = [ 'adam', 'role[monkey],recipe[duck::type]' ]
        @ceth.run
        @node.run_list.should_not include('role[monkey]')
        @node.run_list.should_not include('recipe[duck::type]')
      end
    end
  end
end



