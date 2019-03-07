#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Seth Falcon (<seth@opscode.com>)
# Copyright:: Copyright (c) 2008-2010 Opscode, Inc.
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

require 'seth/data_bag_item'
require 'seth/encrypted_data_bag_item'
require 'seth/json_compat'
require 'tempfile'

describe Seth::ceth::DataBagShow do
  before do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::DataBagShow.new
    @ceth.config[:format] = 'json'
    @rest = double("Seth::REST")
    @ceth.stub(:rest).and_return(@rest)
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end


  it "prints the ids of the data bag items when given a bag name" do
    @ceth.instance_variable_set(:@name_args, ['bag_o_data'])
    data_bag_contents = { "baz"=>"http://localhost:4000/data/bag_o_data/baz",
      "qux"=>"http://localhost:4000/data/bag_o_data/qux"}
    Seth::DataBag.should_receive(:load).and_return(data_bag_contents)
    expected = %q|[
  "baz",
  "qux"
]|
    @ceth.run
    @stdout.string.strip.should == expected
  end

  it "prints the contents of the data bag item when given a bag and item name" do
    @ceth.instance_variable_set(:@name_args, ['bag_o_data', 'an_item'])
    data_item = Seth::DataBagItem.new.tap {|item| item.raw_data = {"id" => "an_item", "zsh" => "victory_through_tabbing"}}

    Seth::DataBagItem.should_receive(:load).with('bag_o_data', 'an_item').and_return(data_item)

    @ceth.run
    Seth::JSONCompat.from_json(@stdout.string).should == data_item.raw_data

  end

  describe "encrypted data bag items" do
    before(:each) do
      @secret = "abc123SECRET"
      @plain_data = {
        "id" => "item_name",
        "greeting" => "hello",
        "nested" => { "a1" => [1, 2, 3], "a2" => { "b1" => true }}
      }
      @enc_data = Seth::EncryptedDataBagItem.encrypt_data_bag_item(@plain_data,
                                                                   @secret)
      @ceth.instance_variable_set(:@name_args, ['bag_name', 'item_name'])

      @secret_file = Tempfile.new("encrypted_data_bag_secret_file_test")
      @secret_file.puts(@secret)
      @secret_file.flush
    end

    after do
      @secret_file.close
      @secret_file.unlink
    end

    it "prints the decrypted contents of an item when given --secret" do
      @ceth.stub(:config).and_return({:secret => @secret})
      Seth::EncryptedDataBagItem.should_receive(:load).
        with('bag_name', 'item_name', @secret).
        and_return(Seth::EncryptedDataBagItem.new(@enc_data, @secret))
      @ceth.run
      Seth::JSONCompat.from_json(@stdout.string).should == @plain_data
    end

    it "prints the decrypted contents of an item when given --secret_file" do
      @ceth.stub(:config).and_return({:secret_file => @secret_file.path})
      Seth::EncryptedDataBagItem.should_receive(:load).
        with('bag_name', 'item_name', @secret).
        and_return(Seth::EncryptedDataBagItem.new(@enc_data, @secret))
      @ceth.run
      Seth::JSONCompat.from_json(@stdout.string).should == @plain_data
    end
  end

  describe "command line parsing" do
    it "prints help if given no arguments" do
      @ceth.instance_variable_set(:@name_args, [])
      lambda { @ceth.run }.should raise_error(SystemExit)
      @stdout.string.should match(/^ceth data bag show BAG \[ITEM\] \(options\)/)
    end
  end

end
