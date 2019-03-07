#
# Author:: Sahil Muthoo (<sahil.muthoo@gmail.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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
require 'highline'

describe Seth::ceth::Status do
  before(:each) do
    node = Seth::Node.new.tap do |n|
      n.automatic_attrs["fqdn"] = "foobar"
      n.automatic_attrs["ohai_time"] = 1343845969
    end
    query = double("Seth::Search::Query")
    query.stub(:search).and_yield(node)
    Seth::Search::Query.stub(:new).and_return(query)
    @ceth  = Seth::ceth::Status.new
    @stdout = StringIO.new
    @ceth.stub(:highline).and_return(HighLine.new(StringIO.new, @stdout))
  end

  describe "run" do
    it "should not colorize output unless it's writing to a tty" do
      @ceth.run
      @stdout.string.match(/foobar/).should_not be_nil
      @stdout.string.match(/\e.*ago/).should be_nil
    end
  end
end
