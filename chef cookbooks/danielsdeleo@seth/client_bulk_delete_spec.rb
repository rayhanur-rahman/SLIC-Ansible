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

describe Seth::ceth::ClientBulkDelete do
  let(:stdout_io) { StringIO.new }
  let(:stdout) {stdout_io.string}
  let(:stderr_io) { StringIO.new }
  let(:stderr) { stderr_io.string }

  let(:ceth) {
    k = Seth::ceth::ClientBulkDelete.new
    k.name_args = name_args
    k.config = option_args
    k.ui.stub(:stdout).and_return(stdout_io)
    k.ui.stub(:stderr).and_return(stderr_io)
    k.ui.stub(:confirm).and_return(ceth_confirm)
    k.ui.stub(:confirm_without_exit).and_return(ceth_confirm)
    k
  }

  let(:name_args) { [ "." ] }
  let(:option_args) { {} }

  let(:ceth_confirm) { true }

  let(:nonvalidator_client_names) { %w{tim dan stephen} }
  let(:nonvalidator_clients) {
    clients = Hash.new

    nonvalidator_client_names.each do |client_name|
      client = Seth::ApiClient.new()
      client.name(client_name)
      client.stub(:destroy).and_return(true)
      clients[client_name] = client
    end

    clients
  }

  let(:validator_client_names) { %w{myorg-validator} }
  let(:validator_clients) {
    clients = Hash.new

    validator_client_names.each do |validator_client_name|
      validator_client = Seth::ApiClient.new()
      validator_client.name(validator_client_name)
      validator_client.stub(:validator).and_return(true)
      validator_client.stub(:destroy).and_return(true)
      clients[validator_client_name] = validator_client
    end

    clients
  }

  let(:client_names) { nonvalidator_client_names + validator_client_names}
  let(:clients) {
    nonvalidator_clients.merge(validator_clients)
  }

  before(:each) do
    Seth::ApiClient.stub(:list).and_return(clients)
  end

  describe "run" do
    describe "without a regex" do
      let(:name_args) { [ ] }

      it "should exit if the regex is not provided" do
        lambda { ceth.run }.should raise_error(SystemExit)
      end
    end

    describe "with any clients" do
      it "should get the list of the clients" do
        Seth::ApiClient.should_receive(:list)
        ceth.run
      end

      it "should print the name of the clients" do
        ceth.run
        client_names.each do |client_name|
          stdout.should include(client_name)
        end
      end

      it "should confirm you really want to delete them" do
        ceth.ui.should_receive(:confirm)
        ceth.run
      end

      describe "without --delete-validators" do
        it "should mention that validator clients wont be deleted" do
          ceth.run
          stdout.should include("Following clients are validators and will not be deleted.")
          info = stdout.index "Following clients are validators and will not be deleted."
          val = stdout.index "myorg-validator"
          (val > info).should be_true
        end

        it "should only delete nonvalidator clients" do
          nonvalidator_clients.each_value do |c|
            c.should_receive(:destroy)
          end

          validator_clients.each_value do |c|
            c.should_not_receive(:destroy)
          end

          ceth.run
        end
      end

      describe "with --delete-validators" do
        let(:option_args) { {:delete_validators => true} }

        it "should mention that validator clients will be deleted" do
          ceth.run
          stdout.should include("The following validators will be deleted")
        end

        it "should confirm twice" do
          ceth.ui.should_receive(:confirm).once
          ceth.ui.should_receive(:confirm_without_exit).once
          ceth.run
        end

        it "should delete all clients" do
          clients.each_value do |c|
            c.should_receive(:destroy)
          end

          ceth.run
        end
      end
    end

    describe "with some clients" do
      let(:name_args) { [ "^ti" ] }

      it "should only delete clients that match the regex" do
        clients["tim"].should_receive(:destroy)
        clients["stephen"].should_not_receive(:destroy)
        clients["dan"].should_not_receive(:destroy)
        clients["myorg-validator"].should_not_receive(:destroy)
        ceth.run
      end
    end
  end
end
