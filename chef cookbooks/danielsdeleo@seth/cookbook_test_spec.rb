#
# Author:: Stephen Delano (<stephen@opscode.com>)$
# Author:: Matthew Kent (<mkent@magoazul.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.$
# Copyright:: Copyright (c) 2010 Matthew Kent
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
Seth::ceth::CookbookTest.load_deps

describe Seth::ceth::CookbookTest do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::CookbookTest.new
    @ceth.config[:cookbook_path] = File.join(seth_SPEC_DATA,'cookbooks')
    @ceth.cookbook_loader.stub(:cookbook_exists?).and_return(true)
    @cookbooks = []
    %w{tats central_market jimmy_johns pho}.each do |cookbook_name|
      @cookbooks << Seth::CookbookVersion.new(cookbook_name)
    end
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should test the cookbook" do
      @ceth.stub(:test_cookbook).and_return(true)
      @ceth.name_args = ["italian"]
      @ceth.should_receive(:test_cookbook).with("italian")
      @ceth.run
    end

    it "should test multiple cookbooks when provided" do
      @ceth.stub(:test_cookbook).and_return(true)
      @ceth.name_args = ["tats", "jimmy_johns"]
      @ceth.should_receive(:test_cookbook).with("tats")
      @ceth.should_receive(:test_cookbook).with("jimmy_johns")
      @ceth.should_not_receive(:test_cookbook).with("central_market")
      @ceth.should_not_receive(:test_cookbook).with("pho")
      @ceth.run
    end

    it "should test both ruby and templates" do
      @ceth.name_args = ["example"]
      @ceth.config[:cookbook_path].should_not be_empty
      Array(@ceth.config[:cookbook_path]).reverse.each do |path|
        @ceth.should_receive(:test_ruby).with(an_instance_of(Seth::Cookbook::SyntaxCheck))
        @ceth.should_receive(:test_templates).with(an_instance_of(Seth::Cookbook::SyntaxCheck))
      end
      @ceth.run
    end

    describe "with -a or --all" do
      it "should test all of the cookbooks" do
        @ceth.stub(:test_cookbook).and_return(true)
        @ceth.config[:all] = true
        @loader = {}
        @loader.stub(:load_cookbooks).and_return(@loader)
        @cookbooks.each do |cookbook|
          @loader[cookbook.name] = cookbook
        end
        @ceth.stub(:cookbook_loader).and_return(@loader)
        @loader.each do |key, cookbook|
          @ceth.should_receive(:test_cookbook).with(cookbook.name)
        end
        @ceth.run
      end
    end

  end
end
