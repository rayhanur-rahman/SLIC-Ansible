#
# Author:: Stephen Delano (<stephen@opscode.com>)
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

describe Seth::ceth::RoleBulkDelete do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::RoleBulkDelete.new
    @ceth.config = {
      :print_after => nil
    }
    @ceth.name_args = ["."]
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
    @ceth.ui.stub(:confirm).and_return(true)
    @roles = Hash.new
    %w{dev staging production}.each do |role_name|
      role = Seth::Role.new()
      role.name(role_name)
      role.stub(:destroy).and_return(true)
      @roles[role_name] = role
    end
    Seth::Role.stub(:list).and_return(@roles)
  end

  describe "run" do

    it "should get the list of the roles" do
      Seth::Role.should_receive(:list).and_return(@roles)
      @ceth.run
    end

    it "should print the roles you are about to delete" do
      @ceth.run
      @stdout.string.should match(/#{@ceth.ui.list(@roles.keys.sort, :columns_down)}/)
    end

    it "should confirm you really want to delete them" do
      @ceth.ui.should_receive(:confirm)
      @ceth.run
    end

    it "should delete each role" do
      @roles.each_value do |r|
        r.should_receive(:destroy)
      end
      @ceth.run
    end

    it "should only delete roles that match the regex" do
      @ceth.name_args = ["dev"]
      @roles["dev"].should_receive(:destroy)
      @roles["staging"].should_not_receive(:destroy)
      @roles["production"].should_not_receive(:destroy)
      @ceth.run
    end

    it "should exit if the regex is not provided" do
      @ceth.name_args = []
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

  end
end
