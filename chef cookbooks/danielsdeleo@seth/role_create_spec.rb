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

describe Seth::ceth::RoleCreate do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::RoleCreate.new
    @ceth.config = {
      :description => nil
    }
    @ceth.name_args = [ "adam" ]
    @ceth.stub(:output).and_return(true)
    @role = Seth::Role.new()
    @role.stub(:save)
    Seth::Role.stub(:new).and_return(@role)
    @ceth.stub(:edit_data).and_return(@role)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should create a new role" do
      Seth::Role.should_receive(:new).and_return(@role)
      @ceth.run
    end

    it "should set the role name" do
      @role.should_receive(:name).with("adam")
      @ceth.run
    end

    it "should not print the role" do
      @ceth.should_not_receive(:output)
      @ceth.run
    end

    it "should allow you to edit the data" do
      @ceth.should_receive(:edit_data).with(@role)
      @ceth.run
    end

    it "should save the role" do
      @role.should_receive(:save)
      @ceth.run
    end

    describe "with -d or --description" do
      it "should set the description" do
        @ceth.config[:description] = "All is bob"
        @role.should_receive(:description).with("All is bob")
        @ceth.run
      end
    end

    describe "with -p or --print-after" do
      it "should pretty print the node, formatted for display" do
        @ceth.config[:print_after] = true
        @ceth.should_receive(:output).with(@role)
        @ceth.run
      end
    end
  end
end
