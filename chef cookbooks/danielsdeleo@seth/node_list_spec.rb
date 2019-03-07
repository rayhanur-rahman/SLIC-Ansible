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

describe Seth::ceth::NodeList do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    Seth::Config[:environment] = nil # reset this value each time, as it is not reloaded
    @ceth = Seth::ceth::NodeList.new
    @ceth.stub(:output).and_return(true)
    @list = {
      "foo" => "http://example.com/foo",
      "bar" => "http://example.com/foo"
    }
    Seth::Node.stub(:list).and_return(@list)
    Seth::Node.stub(:list_by_environment).and_return(@list)
  end

  describe "run" do
    it "should list all of the nodes if -E is not specified" do
      Seth::Node.should_receive(:list).and_return(@list)
      @ceth.run
    end

    it "should pretty print the list" do
      Seth::Node.should_receive(:list).and_return(@list)
      @ceth.should_receive(:output).with([ "bar", "foo" ])
      @ceth.run
    end

    it "should list nodes in the specific environment if -E ENVIRONMENT is specified" do
      Seth::Config[:environment] = "prod"
      Seth::Node.should_receive(:list_by_environment).with("prod").and_return(@list)
      @ceth.run
    end

    describe "with -w or --with-uri" do
      it "should pretty print the hash" do
        @ceth.config[:with_uri] = true
        Seth::Node.should_receive(:list).and_return(@list)
        @ceth.should_receive(:output).with(@list)
        @ceth.run
      end
    end
  end
end

