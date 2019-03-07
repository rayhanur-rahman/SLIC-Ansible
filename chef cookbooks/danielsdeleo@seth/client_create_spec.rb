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

Seth::ceth::ClientCreate.load_deps

describe Seth::ceth::ClientCreate do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::ClientCreate.new
    @ceth.config = {
      :file => nil,
      :admin => false,
      :validator => false
    }
    @ceth.name_args = [ "adam" ]
    @client = Seth::ApiClient.new
    @client.stub(:save).and_return({ 'private_key' => '' })
    @ceth.stub(:edit_data).and_return(@client)
    @ceth.stub(:puts)
    Seth::ApiClient.stub(:new).and_return(@client)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  describe "run" do
    it "should create a new Client" do
      Seth::ApiClient.should_receive(:new).and_return(@client)
      @ceth.run
      @stdout.string.should match /created client.+adam/i
    end

    it "should set the Client name" do
      @client.should_receive(:name).with("adam")
      @ceth.run
    end

    it "by default it is not an admin" do
      @client.should_receive(:admin).with(false)
      @ceth.run
    end

    it "by default it is not a validator" do
      @client.should_receive(:validator).with(false)
      @ceth.run
    end

    it "should allow you to edit the data" do
      @ceth.should_receive(:edit_data).with(@client)
      @ceth.run
    end

    it "should save the Client" do
      @client.should_receive(:save)
      @ceth.run
    end

    describe "with -f or --file" do
      it "should write the private key to a file" do
        @ceth.config[:file] = "/tmp/monkeypants"
        @client.stub(:save).and_return({ 'private_key' => "woot" })
        filehandle = double("Filehandle")
        filehandle.should_receive(:print).with('woot')
        File.should_receive(:open).with("/tmp/monkeypants", "w").and_yield(filehandle)
        @ceth.run
      end
    end

    describe "with -a or --admin" do
      it "should create an admin client" do
        @ceth.config[:admin] = true
        @client.should_receive(:admin).with(true)
        @ceth.run
      end
    end

    describe "with --validator" do
      it "should create an validator client" do
        @ceth.config[:validator] = true
        @client.should_receive(:validator).with(true)
        @ceth.run
      end
    end

  end
end
