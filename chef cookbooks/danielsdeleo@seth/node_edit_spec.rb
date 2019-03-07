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
Seth::ceth::NodeEdit.load_deps

describe Seth::ceth::NodeEdit do

  # helper to convert the view from Seth objects into Ruby objects representing JSON
  def deserialized_json_view
    actual = Seth::JSONCompat.from_json(seth::JSONCompat.to_json_pretty(@ceth.node_editor.send(:view)))
  end

  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::NodeEdit.new
    @ceth.config = {
      :editor => 'cat',
      :attribute => nil,
      :print_after => nil
    }
    @ceth.name_args = [ "adam" ]
    @node = Seth::Node.new()
  end

  it "should load the node" do
    Seth::Node.should_receive(:load).with("adam").and_return(@node)
    @ceth.node
  end

  describe "after loading the node" do
    before do
      @ceth.stub(:node).and_return(@node)
      @node.automatic_attrs = {:go => :away}
      @node.default_attrs = {:hide => :me}
      @node.override_attrs = {:dont => :show}
      @node.normal_attrs = {:do_show => :these}
      @node.seth_environment("prod")
      @node.run_list("recipe[foo]")
    end

    it "creates a view of the node without attributes from roles or ohai" do
      actual = deserialized_json_view
      actual.should_not have_key("automatic")
      actual.should_not have_key("override")
      actual.should_not have_key("default")
      actual["normal"].should == {"do_show" => "these"}
      actual["run_list"].should == ["recipe[foo]"]
      actual["seth_environment"].should == "prod"
    end

    it "shows the extra attributes when given the --all option" do
      @ceth.config[:all_attributes] = true

      actual = deserialized_json_view
      actual["automatic"].should == {"go" => "away"}
      actual["override"].should == {"dont" => "show"}
      actual["default"].should == {"hide" => "me"}
      actual["normal"].should == {"do_show" => "these"}
      actual["run_list"].should == ["recipe[foo]"]
      actual["seth_environment"].should == "prod"
    end

    it "does not consider unedited data updated" do
      view = deserialized_json_view
      @ceth.node_editor.send(:apply_updates, view)
      @ceth.node_editor.should_not be_updated
    end

    it "considers edited data updated" do
      view = deserialized_json_view
      view["run_list"] << "role[fuuu]"
      @ceth.node_editor.send(:apply_updates, view)
      @ceth.node_editor.should be_updated
    end

  end

  describe "edit_node" do

    before do
      @ceth.stub(:node).and_return(@node)
    end

    let(:subject) { @ceth.node_editor.edit_node }

    it "raises an exception when editing is disabled" do
      @ceth.config[:disable_editing] = true
      expect{ subject }.to raise_error(SystemExit)
    end

    it "raises an exception when the editor is not set" do
      @ceth.config[:editor] = nil
      expect{ subject }.to raise_error(SystemExit)
    end

  end

end

