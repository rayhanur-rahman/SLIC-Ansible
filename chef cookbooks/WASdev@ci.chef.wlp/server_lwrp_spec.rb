#
# (C) Copyright IBM Corporation 2013.
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

require "chefspec"

describe "wlp_server" do

  context "start" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(
        :platform => "ubuntu", 
        :version => "12.04", 
        :step_into => [ "wlp_server" ],                                
        :cookbook_path => ["..", "spec/cookbooks"])
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["config"]["basic"] = {}
      chef_run.converge "test::server_basic"
    }

    let (:serverName) {
      "testStartServer"
    }

    it "create init.d script" do
      initdFile = "/etc/init.d/wlp-testStartServer"
      expect(chef_run).to create_template(initdFile).with(:user => 'root', :group => 'root')
    end

    ### TODO: Check for notifications (needs newer ChefSpec)

    it "enable service at boot" do
      expect(chef_run).to enable_service("wlp-#{serverName}")
    end

    it "start service" do
      expect(chef_run).to start_service("wlp-#{serverName}")
    end

    it "not stop service" do
      expect(chef_run).not_to stop_service("wlp-#{serverName}")
    end

  end

  context "stop" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(
        :platform => "ubuntu", 
        :version => "12.04", 
        :step_into => [ "wlp_server" ],     
        :cookbook_path => ["..", "spec/cookbooks"])
      chef_run.node.set["wlp"]["base_dir"] = "/liberty"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["config"]["basic"] = {}
      return chef_run
    }

    let (:serverName) {
      "testStopServer"
    }

    before(:each) { 
      File.stub(:exists?).and_call_original
    }

    it "stop service" do
      File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(true)
      chef_run.converge "test::server_basic"
      expect(chef_run).to stop_service("wlp-#{serverName}")
      expect(chef_run).not_to enable_service("wlp-#{serverName}")
    end

    it "not stop service" do
      File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(false)
      chef_run.converge "test::server_basic"
      expect(chef_run).not_to stop_service("wlp-#{serverName}")
      expect(chef_run).not_to enable_service("wlp-#{serverName}")
    end

  end

  context "destroy" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(
        :platform => "ubuntu", 
        :version => "12.04", 
        :step_into => [ "wlp_server" ],     
        :cookbook_path => ["..", "spec/cookbooks"])
      chef_run.node.set["wlp"]["base_dir"] = "/liberty"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["config"]["basic"] = {}
      return chef_run
    }

    let (:serverName) {
      "testDestroyServer"
    }

    let (:serverDir) {
      "#{chef_run.node['wlp']['base_dir']}/wlp/usr/servers/#{serverName}"
    }

    before (:each) { 
      ::File.stub(:exists?).and_call_original
    }

    it "stop service and delete" do
      ::File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(true)
      chef_run.converge "test::server_basic"
      expect(chef_run).to stop_service("wlp-#{serverName}")
      expect(chef_run).not_to enable_service("wlp-#{serverName}")
      expect(chef_run).to delete_directory(serverDir)
    end

    it "not stop service and delete" do
      ::File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(false)
      chef_run.converge "test::server_basic"
      expect(chef_run).not_to stop_service("wlp-#{serverName}")
      expect(chef_run).not_to enable_service("wlp-#{serverName}")
      expect(chef_run).not_to delete_directory(serverDir)
    end

  end

  context "create" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(
        :platform => "ubuntu", 
        :version => "12.04", 
        :step_into => [ "wlp_server" ],     
        :cookbook_path => ["..", "spec/cookbooks"])
      chef_run.node.set["wlp"]["base_dir"] = "/liberty"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["config"]["basic"] = {}
      return chef_run
    }

    let (:serverName) {
      "testCreateServer"
    }

    let (:serverDir) {
      "#{chef_run.node['wlp']['base_dir']}/wlp/usr/servers/#{serverName}"
    }

    before (:each) { 
      ::File.stub(:exists?).and_call_original
    }

    it "create server" do
      ::File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(false)
      chef_run.converge "test::server_basic"
      expect(chef_run).to create_directory(serverDir)
    end

    it "does not create server" do
      ::File.should_receive(:exists?).with(/servers\/#{serverName}/).and_return(true)
      chef_run.converge "test::server_basic"
      expect(chef_run).not_to create_directory(serverDir)
    end

  end
end
