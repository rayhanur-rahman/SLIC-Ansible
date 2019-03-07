#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Matthew Kent (<mkent@magoazul.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

describe Seth::ceth::CookbookMetadataFromFile do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @src = File.expand_path(File.join(seth_SPEC_DATA, "metadata", "quick_start", "metadata.rb"))
    @tgt = File.expand_path(File.join(seth_SPEC_DATA, "metadata", "quick_start", "metadata.json"))
    @ceth = Seth::ceth::CookbookMetadataFromFile.new
    @ceth.name_args = [ @src ]
    @ceth.stub(:to_json_pretty).and_return(true)
    @md = Seth::Cookbook::Metadata.new
    Seth::Cookbook::Metadata.stub(:new).and_return(@md)
    $stdout.stub(:write)
  end

  after do
    if File.exists?(@tgt)
      File.unlink(@tgt)
    end
  end

  describe "run" do
    it "should determine cookbook name from path" do
      @md.should_receive(:name).with()
      @md.should_receive(:name).with("quick_start")
      @ceth.run
    end

    it "should load the metadata source" do
      @md.should_receive(:from_file).with(@src)
      @ceth.run
    end

    it "should write out the metadata to the correct location" do
      File.should_receive(:open).with(@tgt, "w")
      @ceth.run
    end

    it "should generate json from the metadata" do
      Seth::JSONCompat.should_receive(:to_json_pretty).with(@md)
      @ceth.run
    end

  end
end
