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

Seth::ceth::RoleFromFile.load_deps

describe Seth::ceth::RoleFromFile do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::RoleFromFile.new
    @ceth.config = {
      :print_after => nil
    }
    @ceth.name_args = [ "adam.rb" ]
    @ceth.stub(:output).and_return(true)
    @ceth.stub(:confirm).and_return(true)
    @role = Seth::Role.new()
    @role.stub(:save)
    @ceth.loader.stub(:load_from).and_return(@role)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should load from a file" do
      @ceth.loader.should_receive(:load_from).with('roles', 'adam.rb').and_return(@role)
      @ceth.run
    end

    it "should not print the role" do
      @ceth.should_not_receive(:output)
      @ceth.run
    end

    describe "with -p or --print-after" do
      it "should print the role" do
        @ceth.config[:print_after] = true
        @ceth.should_receive(:output)
        @ceth.run
      end
    end
  end

  describe "run with multiple arguments" do
    it "should load each file" do
      @ceth.name_args = [ "adam.rb", "caleb.rb" ]
      @ceth.loader.should_receive(:load_from).with('roles', 'adam.rb').and_return(@role)
      @ceth.loader.should_receive(:load_from).with('roles', 'caleb.rb').and_return(@role)
      @ceth.run
    end
  end

end
