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

describe Seth::ceth::RoleEdit do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::RoleEdit.new
    @ceth.config[:print_after] = nil
    @ceth.name_args = [ "adam" ]
    @ceth.ui.stub(:output).and_return(true)
    @role = Seth::Role.new()
    @role.stub(:save)
    Seth::Role.stub(:load).and_return(@role)
    @ceth.ui.stub(:edit_data).and_return(@role)
    @ceth.ui.stub(:msg)
  end

  describe "run" do
    it "should load the role" do
      Seth::Role.should_receive(:load).with("adam").and_return(@role)
      @ceth.run
    end

    it "should edit the role data" do
      @ceth.ui.should_receive(:edit_data).with(@role)
      @ceth.run
    end

    it "should save the edited role data" do
      pansy = Seth::Role.new

      @role.name("new_role_name")
      @ceth.ui.should_receive(:edit_data).with(@role).and_return(pansy)
      pansy.should_receive(:save)
      @ceth.run
    end

    it "should not save the unedited role data" do
      pansy = Seth::Role.new

      @ceth.ui.should_receive(:edit_data).with(@role).and_return(pansy)
      pansy.should_not_receive(:save)
      @ceth.run

    end

    it "should not print the role" do
      @ceth.ui.should_not_receive(:output)
      @ceth.run
    end

    describe "with -p or --print-after" do
      it "should pretty print the role, formatted for display" do
        @ceth.config[:print_after] = true
        @ceth.ui.should_receive(:output).with(@role)
        @ceth.run
      end
    end
  end
end


