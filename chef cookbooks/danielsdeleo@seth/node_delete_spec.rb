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

describe Seth::ceth::NodeDelete do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeDelete.new
    @ceth.config = {
      :print_after => nil
    }
    @ceth.name_args = [ "adam" ]
    @ceth.stub(:output).and_return(true)
    @ceth.stub(:confirm).and_return(true)
    @node = Seth::Node.new()
    @node.stub(:destroy).and_return(true)
    Seth::Node.stub(:load).and_return(@node)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should confirm that you want to delete" do
      @ceth.should_receive(:confirm)
      @ceth.run
    end

    it "should load the node" do
      Seth::Node.should_receive(:load).with("adam").and_return(@node)
      @ceth.run
    end

    it "should delete the node" do
      @node.should_receive(:destroy).and_return(@node)
      @ceth.run
    end

    it "should not print the node" do
      @ceth.should_not_receive(:output).with("poop")
      @ceth.run
    end

    describe "with -p or --print-after" do
      it "should pretty print the node, formatted for display" do
        @ceth.config[:print_after] = true
        @ceth.should_receive(:format_for_display).with(@node).and_return("poop")
        @ceth.should_receive(:output).with("poop")
        @ceth.run
      end
    end
  end
end
