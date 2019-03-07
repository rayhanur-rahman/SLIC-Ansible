#
# Author:: Stephen Delano (<stephen@ospcode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

describe Seth::ceth::EnvironmentShow do
  before(:each) do
    @ceth = Seth::ceth::EnvironmentShow.new
    @ceth.stub(:msg).and_return true
    @ceth.stub(:output).and_return true
    @ceth.stub(:show_usage).and_return true
    @ceth.name_args = [ "production" ]

    @environment = Seth::Environment.new
    @environment.name("production")
    @environment.description("Look at me!")
    Seth::Environment.stub(:load).and_return @environment
  end

  it "should load the environment" do
    Seth::Environment.should_receive(:load).with("production")
    @ceth.run
  end

  it "should pretty print the environment, formatted for display" do
    @ceth.should_receive(:format_for_display).with(@environment)
    @ceth.should_receive(:output)
    @ceth.run
  end

  it "should show usage and exit when no environment name is provided" do
    @ceth.name_args = []
    @ceth.ui.should_receive(:fatal)
    @ceth.should_receive(:show_usage)
    lambda { @ceth.run }.should raise_error(SystemExit)
  end
end
