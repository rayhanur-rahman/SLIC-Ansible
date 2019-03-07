#
# Author:: Jimmy McCrory (<jimmy.mccrory@gmail.com>)
# Copyright:: Copyright (c) 2014 Jimmy McCrory
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

describe Seth::ceth::NodeEnvironmentSet do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeEnvironmentSet.new
    @ceth.name_args = [ "adam", "bar" ]
    @ceth.stub(:output).and_return(true)
    @node = Seth::Node.new()
    @node.name("cethtest-node")
    @node.seth_environment << "foo"
    @node.stub(:save).and_return(true)
    Seth::Node.stub(:load).and_return(@node)
  end

  describe "run" do
    it "should load the node" do
      Seth::Node.should_receive(:load).with("adam")
      @ceth.run
    end

    it "should update the environment" do
      @ceth.run
      @node.seth_environment.should == 'bar'
    end

    it "should save the node" do
      @node.should_receive(:save)
      @ceth.run
    end

    it "should print the environment" do
      @ceth.should_receive(:output).and_return(true)
      @ceth.run
    end

    describe "with no environment" do
      # Set up outputs for inspection later
      before(:each) do
        @stdout = StringIO.new
        @stderr = StringIO.new

        @ceth.ui.stub(:stdout).and_return(@stdout)
        @ceth.ui.stub(:stderr).and_return(@stderr)
      end

      it "should exit" do
        @ceth.name_args = [ "adam" ]
        lambda { @ceth.run }.should raise_error SystemExit
      end

      it "should show the user the usage and an error" do
        @ceth.name_args = [ "adam" ]

        begin ; @ceth.run ; rescue SystemExit ; end

        @stdout.string.should eq "USAGE: ceth node environment set NODE ENVIRONMENT\n"
        @stderr.string.should eq "FATAL: You must specify a node name and an environment.\n"
      end
    end
  end
end
