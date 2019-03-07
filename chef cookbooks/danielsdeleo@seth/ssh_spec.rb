#
# Author:: Daniel DeLeo (<dan@opscode.com>)
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
require 'tiny_server'

describe Seth::ceth::Ssh do

  before(:all) do
    Seth::ceth::Ssh.load_deps
    @server = TinyServer::Manager.new
    @server.start
  end

  after(:all) do
    @server.stop
  end

  describe "identity file" do
    context "when ceth[:ssh_identity_file] is set" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_identity_file] = "~/.ssh/aws.rsa"
      end

      it "uses the ssh_identity_file" do
        @ceth.run
        @ceth.config[:identity_file].should == "~/.ssh/aws.rsa"
      end
    end

    context "when ceth[:ssh_identity_file] is set and frozen" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_identity_file] = "~/.ssh/aws.rsa".freeze
      end

      it "uses the ssh_identity_file" do
        @ceth.run
        @ceth.config[:identity_file].should == "~/.ssh/aws.rsa"
      end
    end

    context "when -i is provided" do
      before do
        setup_ceth(['-i ~/.ssh/aws.rsa', '*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_identity_file] = nil
      end

      it "should use the value on the command line" do
        @ceth.run
        @ceth.config[:identity_file].should == "~/.ssh/aws.rsa"
      end

      it "should override what is set in ceth.rb" do
        Seth::Config[:ceth][:ssh_identity_file] = "~/.ssh/other.rsa"
        @ceth.run
        @ceth.config[:identity_file].should == "~/.ssh/aws.rsa"
      end
    end

    context "when ceth[:ssh_identity_file] is not provided]" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_identity_file] = nil
      end

      it "uses the default" do
        @ceth.run
        @ceth.config[:identity_file].should == nil
      end
    end
  end

  describe "port" do
    context "when -p 31337 is provided" do
      before do
        setup_ceth(['-p 31337', '*:*', 'uptime'])
      end

      it "uses the ssh_port" do
        @ceth.run
        @ceth.config[:ssh_port].should == "31337"
      end
    end
  end

  describe "user" do
    context "when ceth[:ssh_user] is set" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_user] = "ubuntu"
      end

      it "uses the ssh_user" do
        @ceth.run
        @ceth.config[:ssh_user].should == "ubuntu"
      end
    end

    context "when ceth[:ssh_user] is set and frozen" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_user] = "ubuntu".freeze
      end

      it "uses the ssh_user" do
        @ceth.run
        @ceth.config[:ssh_user].should == "ubuntu"
      end
    end

    context "when -x is provided" do
      before do
        setup_ceth(['-x ubuntu', '*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_user] = nil
      end

      it "should use the value on the command line" do
        @ceth.run
        @ceth.config[:ssh_user].should == "ubuntu"
      end

      it "should override what is set in ceth.rb" do
        Seth::Config[:ceth][:ssh_user] = "root"
        @ceth.run
        @ceth.config[:ssh_user].should == "ubuntu"
      end
    end

    context "when ceth[:ssh_user] is not provided]" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_user] = nil
      end

      it "uses the default (current user)" do
        @ceth.run
        @ceth.config[:ssh_user].should == nil
      end
    end
  end

  describe "attribute" do
    context "when ceth[:ssh_attribute] is set" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_attribute] = "ec2.public_hostname"
      end

      it "uses the ssh_attribute" do
        @ceth.run
        @ceth.config[:attribute].should == "ec2.public_hostname"
      end
    end

    context "when ceth[:ssh_attribute] is not provided]" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_attribute] = nil
      end

      it "uses the default" do
        @ceth.run
        @ceth.config[:attribute].should == "fqdn"
      end
    end

    context "when -a ec2.public_ipv4 is provided" do
      before do
        setup_ceth(['-a ec2.public_hostname', '*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_attribute] = nil
      end

      it "should use the value on the command line" do
        @ceth.run
        @ceth.config[:attribute].should == "ec2.public_hostname"
      end

      it "should override what is set in ceth.rb" do
        # This is the setting imported from ceth.rb
        Seth::Config[:ceth][:ssh_attribute] = "fqdn"
        # Then we run ceth with the -a flag, which sets the above variable
        setup_ceth(['-a ec2.public_hostname', '*:*', 'uptime'])
        @ceth.run
        @ceth.config[:attribute].should == "ec2.public_hostname"
      end
    end
  end

  describe "gateway" do
    context "when ceth[:ssh_gateway] is set" do
      before do
        setup_ceth(['*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_gateway] = "user@ec2.public_hostname"
      end

      it "uses the ssh_gateway" do
        @ceth.session.should_receive(:via).with("ec2.public_hostname", "user", {})
        @ceth.run
        @ceth.config[:ssh_gateway].should == "user@ec2.public_hostname"
      end
    end

    context "when -G user@ec2.public_hostname is provided" do
      before do
        setup_ceth(['-G user@ec2.public_hostname', '*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_gateway] = nil
      end

      it "uses the ssh_gateway" do
        @ceth.session.should_receive(:via).with("ec2.public_hostname", "user", {})
        @ceth.run
        @ceth.config[:ssh_gateway].should == "user@ec2.public_hostname"
      end
    end

    context "when the gateway requires a password" do
      before do
        setup_ceth(['-G user@ec2.public_hostname', '*:*', 'uptime'])
        Seth::Config[:ceth][:ssh_gateway] = nil
        @ceth.session.stub(:via) do |host, user, options|
          raise Net::SSH::AuthenticationFailed unless options[:password]
        end
      end

      it "should prompt the user for a password" do
        @ceth.ui.should_receive(:ask).with("Enter the password for user@ec2.public_hostname: ").and_return("password")
        @ceth.run
      end
    end
  end

  def setup_ceth(params=[])
    @ceth = Seth::ceth::Ssh.new(params)
    # We explicitly avoid running #configure_seth, which would read a ceth.rb
    # if available, but #merge_configs (which is called by #configure_seth) is
    # necessary to have default options merged in.
    @ceth.merge_configs
    @ceth.stub(:ssh_command).and_return { 0 }
    @api = TinyServer::API.instance
    @api.clear

    Seth::Config[:node_name] = nil
    Seth::Config[:client_key] = nil
    Seth::Config[:seth_server_url] = 'http://localhost:9000'

    @api.get("/search/node?q=*:*&sort=X_seth_id_seth_X%20asc&start=0&rows=1000", 200) {
      %({"total":1, "start":0, "rows":[{"name":"i-xxxxxxxx", "json_class":"Seth::Node", "automatic":{"fqdn":"the.fqdn", "ec2":{"public_hostname":"the_public_hostname"}},"recipes":[]}]})
    }
  end

end
