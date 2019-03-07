#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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
require 'seth/ceth/core/bootstrap_context'

describe Seth::ceth::Core::BootstrapContext do
  let(:config) { {:foo => :bar} }
  let(:run_list) { Seth::RunList.new('recipe[tmux]', 'role[base]') }
  let(:seth_config) do
    {
      :validation_key => File.join(seth_SPEC_DATA, 'ssl', 'private_key.pem'),
      :seth_server_url => 'http://seth.example.com:4444',
      :validation_client_name => 'seth-validator-testing'
    }
  end
  let(:secret_file) { File.join(seth_SPEC_DATA, 'bootstrap', 'encrypted_data_bag_secret') }

  subject(:bootstrap_context) { described_class.new(config, run_list, seth_config) }

  it "installs the same version of seth on the remote host" do
    bootstrap_context.bootstrap_version_string.should eq "--version #{Seth::VERSION}"
  end

  it "runs seth with the first-boot.json in the _default environment" do
    bootstrap_context.start_seth.should eq "seth-client -j /etc/seth/first-boot.json -E _default"
  end

  describe "when in verbosity mode" do
    let(:config) { {:verbosity => 2} }
    it "adds '-l debug' when verbosity is >= 2" do
      bootstrap_context.start_seth.should eq "seth-client -j /etc/seth/first-boot.json -l debug -E _default"
    end
  end

  it "reads the validation key" do
    bootstrap_context.validation_key.should eq IO.read(File.join(seth_SPEC_DATA, 'ssl', 'private_key.pem'))
  end

  it "generates the config file data" do
    expected=<<-EXPECTED
log_location     STDOUT
seth_server_url  "http://seth.example.com:4444"
validation_client_name "seth-validator-testing"
# Using default node name (fqdn)
EXPECTED
    bootstrap_context.config_content.should eq expected
  end

  it "does not set a default log_level" do
    expect(bootstrap_context.config_content).not_to match(/log_level/)
  end

  describe "alternate seth-client path" do
    let(:seth_config){ {:seth_client_path => '/usr/local/bin/seth-client'} }
    it "runs seth-client from another path when specified" do
      bootstrap_context.start_seth.should eq "/usr/local/bin/seth-client -j /etc/seth/first-boot.json -E _default"
    end
  end

  describe "validation key path that contains a ~" do
    let(:seth_config){ {:validation_key => '~/my.key'} }
    it "reads the validation key when it contains a ~" do
      IO.should_receive(:read).with(File.expand_path("my.key", ENV['HOME']))
      bootstrap_context.validation_key
    end
  end

  describe "when an explicit node name is given" do
    let(:config){ {:seth_node_name => 'foobar.example.com' }}
    it "sets the node name in the client.rb" do
      bootstrap_context.config_content.should match(/node_name "foobar\.example\.com"/)
    end
  end

  describe "when bootstrapping into a specific environment" do
    let(:seth_config){ {:environment => "prodtastic"} }
    it "starts seth in the configured environment" do
      bootstrap_context.start_seth.should == 'seth-client -j /etc/seth/first-boot.json -E prodtastic'
    end
  end

  describe "when installing a prerelease version of seth" do
    let(:config){ {:prerelease => true }}
    it "supplies --prerelease as the version string" do
      bootstrap_context.bootstrap_version_string.should eq '--prerelease'
    end
  end

  describe "when installing an explicit version of seth" do
    let(:seth_config) do
      {
        :ceth => { :bootstrap_version => '123.45.678' }
      }
    end
    it "gives --version $VERSION as the version string" do
      bootstrap_context.bootstrap_version_string.should eq '--version 123.45.678'
    end
  end

  describe "when JSON attributes are given" do
    let(:config) { {:first_boot_attributes => {:baz => :quux}} }
    it "adds the attributes to first_boot" do
      bootstrap_context.first_boot.to_json.should eq({:baz => :quux, :run_list => run_list}.to_json)
    end
  end

  describe "when JSON attributes are NOT given" do
    it "sets first_boot equal to run_list" do
      bootstrap_context.first_boot.to_json.should eq({:run_list => run_list}.to_json)
    end
  end

  describe "when an encrypted_data_bag_secret is provided" do
    context "via config[:secret]" do
      let(:seth_config) do
        {
          :ceth => {:secret => "supersekret" }
        }
      end
      it "reads the encrypted_data_bag_secret" do
        bootstrap_context.encrypted_data_bag_secret.should eq "supersekret"
      end
    end

    context "via config[:secret_file]" do
      let(:seth_config) do
        {
          :ceth => {:secret_file =>  secret_file}
        }
      end
      it "reads the encrypted_data_bag_secret" do
        bootstrap_context.encrypted_data_bag_secret.should eq IO.read(secret_file)
      end
    end
  end

  describe "to support compatibility with existing templates" do
    it "sets the @config instance variable" do
      bootstrap_context.instance_variable_get(:@config).should eq config
    end

    it "sets the @run_list instance variable" do
      bootstrap_context.instance_variable_get(:@run_list).should eq run_list
    end

    describe "accepts encrypted_data_bag_secret via Seth::Config" do
      let(:seth_config) { {:encrypted_data_bag_secret => secret_file }}
      it "reads the encrypted_data_bag_secret" do
        bootstrap_context.encrypted_data_bag_secret.should eq IO.read(secret_file)
      end
    end
  end

  describe "when a bootstrap_version is specified" do
    let(:seth_config) do
      {
        :ceth => {:bootstrap_version => "11.12.4" }
      }
    end

    it "should send the full version to the installer" do
      bootstrap_context.latest_current_seth_version_string.should eq("-v 11.12.4")
    end
  end

  describe "when a pre-release bootstrap_version is specified" do
    let(:seth_config) do
      {
        :ceth => {:bootstrap_version => "11.12.4.rc.0" }
      }
    end

    it "should send the full version to the installer and set the pre-release flag" do
      bootstrap_context.latest_current_seth_version_string.should eq("-v 11.12.4.rc.0 -p")
    end
  end

  describe "when a bootstrap_version is not specified" do
    it "should send the latest current to the installer" do
      # Intentionally hard coded in order not to replicate the logic.
      bootstrap_context.latest_current_seth_version_string.should eq("-v 11")
    end
  end
end
