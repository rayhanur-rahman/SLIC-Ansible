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

Seth::ceth::NodeFromFile.load_deps

describe Seth::ceth::NodeFromFile do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeFromFile.new
    @ceth.config = {
      :print_after => nil
    }
    @ceth.name_args = [ "adam.rb" ]
    @ceth.stub(:output).and_return(true)
    @ceth.stub(:confirm).and_return(true)
    @node = Seth::Node.new()
    @node.stub(:save)
    @ceth.loader.stub(:load_from).and_return(@node)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should load from a file" do
      @ceth.loader.should_receive(:load_from).with('nodes', 'adam.rb').and_return(@node)
      @ceth.run
    end

    it "should not print the Node" do
      @ceth.should_not_receive(:output)
      @ceth.run
    end

    describe "with -p or --print-after" do
      it "should print the Node" do
        @ceth.config[:print_after] = true
        @ceth.should_receive(:output)
        @ceth.run
      end
    end
  end
end
