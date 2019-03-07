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

describe Seth::ceth::EnvironmentEdit do
  before(:each) do
    @ceth = Seth::ceth::EnvironmentEdit.new
    @ceth.ui.stub(:msg).and_return true
    @ceth.ui.stub(:output).and_return true
    @ceth.ui.stub(:show_usage).and_return true
    @ceth.name_args = [ "production" ]

    @environment = Seth::Environment.new
    @environment.name("production")
    @environment.description("Please edit me")
    @environment.stub(:save).and_return true
    Seth::Environment.stub(:load).and_return @environment
    @ceth.ui.stub(:edit_data).and_return @environment
  end

  it "should load the environment" do
    Seth::Environment.should_receive(:load).with("production")
    @ceth.run
  end

  it "should let you edit the environment" do
    @ceth.ui.should_receive(:edit_data).with(@environment)
    @ceth.run
  end

  it "should save the edited environment data" do
    pansy = Seth::Environment.new

    @environment.name("new_environment_name")
    @ceth.ui.should_receive(:edit_data).with(@environment).and_return(pansy)
    pansy.should_receive(:save)
    @ceth.run
  end

  it "should not save the unedited environment data" do
    @environment.should_not_receive(:save)
    @ceth.run
  end

  it "should not print the environment" do
    @ceth.should_not_receive(:output)
    @ceth.run
  end

  it "shoud show usage and exit when no environment name is provided" do
    @ceth.name_args = []
    @ceth.should_receive(:show_usage)
    lambda { @ceth.run }.should raise_error(SystemExit)
  end

  describe "with --print-after" do
    it "should pretty print the environment, formatted for display" do
      @ceth.config[:print_after] = true
      @ceth.ui.should_receive(:output).with(@environment)
      @ceth.run
    end
  end
end
