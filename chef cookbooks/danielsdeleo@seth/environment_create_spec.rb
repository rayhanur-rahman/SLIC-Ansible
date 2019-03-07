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

describe Seth::ceth::EnvironmentCreate do
  before(:each) do
    @ceth = Seth::ceth::EnvironmentCreate.new
    @ceth.stub(:msg).and_return true
    @ceth.stub(:output).and_return true
    @ceth.stub(:show_usage).and_return true
    @ceth.name_args = [ "production" ]

    @environment = Seth::Environment.new
    @environment.stub(:save)

    Seth::Environment.stub(:new).and_return @environment
    @ceth.stub(:edit_data).and_return @environment
  end

  describe "run" do
    it "should create a new environment" do
      Seth::Environment.should_receive(:new)
      @ceth.run
    end

    it "should set the environment name" do
      @environment.should_receive(:name).with("production")
      @ceth.run
    end

    it "should not print the environment" do
      @ceth.should_not_receive(:output)
      @ceth.run
    end

    it "should prompt you to edit the data" do
      @ceth.should_receive(:edit_data).with(@environment)
      @ceth.run
    end

    it "should save the environment" do
      @environment.should_receive(:save)
      @ceth.run
    end

    it "should show usage and exit when no environment name is provided" do
      @ceth.name_args = [ ]
      @ceth.ui.should_receive(:fatal)
      @ceth.should_receive(:show_usage)
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    describe "with --description" do
      before(:each) do
        @ceth.config[:description] = "This is production"
      end

      it "should set the description" do
        @environment.should_receive(:description).with("This is production")
        @ceth.run
      end
    end

    describe "with --print-after" do
      before(:each) do
        @ceth.config[:print_after] = true
      end

      it "should pretty print the environment, formatted for display" do
        @ceth.should_receive(:output).with(@environment)
        @ceth.run
      end
    end
  end
end
