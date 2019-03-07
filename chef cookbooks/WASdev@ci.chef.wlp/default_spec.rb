#
# (C) Copyright IBM Corporation 2014.
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

describe "wlp::default" do

  context "archive::basic" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["archive"]["base_url"] = "http://example.com/"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["archive"]["runtime"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/runtime.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extended.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extras.jar"
      chef_run.converge "wlp::default"
    }

    it "include archive_install" do
      expect(chef_run).to include_recipe("wlp::_archive_install")
    end

    it "include java recipe" do
      expect(chef_run).to include_recipe("java::default")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "download runtime.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/runtime.jar")
    end

    it "download extended.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/extended.jar")
    end

    it "not download extras.jar" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/extras.jar")
    end

    it  "install runtime.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/runtime.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extended.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extended.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "not install extras.jar" do
      expect(chef_run).not_to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extras.jar --acceptLicense #{chef_run.node["wlp"]["archive"]["extras"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  ### Install runtime without extended but with extras archive and non-default user/group"
  context "archive::basic -extended and +extras" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["user"] = "liberty"
      chef_run.node.set["wlp"]["group"] = "admin"
      chef_run.node.set["wlp"]["archive"]["base_url"] = "http://example.com/"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["archive"]["runtime"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/runtime.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extended.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["install"] = false
      chef_run.node.set["wlp"]["archive"]["extras"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extras.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["install"] = true
      chef_run.converge "wlp::default"
    }

    it "include archive_install" do
      expect(chef_run).to include_recipe("wlp::_archive_install")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "download runtime.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/runtime.jar")
    end

    it "not download extended.jar" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/extended.jar")
    end

    it "download extras.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/extras.jar")
    end

    it  "install runtime.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/runtime.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "not install extended.jar" do
      expect(chef_run).not_to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extended.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extras.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extras.jar --acceptLicense #{chef_run.node["wlp"]["archive"]["extras"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  ### Install runtime, extended, extras "
  context "archive:all" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["archive"]["base_url"] = "http://example.com/"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["base_dir"] = "/liberty"
      chef_run.node.set["wlp"]["user_dir"] = "/liberty/config"
      chef_run.node.set["wlp"]["archive"]["runtime"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/runtime.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extended.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["install"] = true
      chef_run.node.set["wlp"]["archive"]["extras"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extras.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["install"] = true
      chef_run.node.set["wlp"]["archive"]["extras"]["base_dir"] = "/liberty/extras"
      chef_run.converge "wlp::default"
    }

    it "include archive_install" do
      expect(chef_run).to include_recipe("wlp::_archive_install")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "create user config directory" do
      baseDir = chef_run.node["wlp"]["user_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "download runtime.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/runtime.jar")
    end

    it "download extended.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/extended.jar")
    end

    it "download extras.jar" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/extras.jar")
    end

    it  "install runtime.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/runtime.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extended.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extended.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extras.jar" do
      expect(chef_run).to run_execute("java -jar #{Chef::Config[:file_cache_path]}/extras.jar --acceptLicense #{chef_run.node["wlp"]["archive"]["extras"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  ### Install using zip 
  context "zip::basic" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["install_method"] = "zip"
      chef_run.node.set["wlp"]["zip"]["url"] = "http://example.com/wlp.zip"
      chef_run.converge "wlp::default"
    }

    it "include zip_install" do
      expect(chef_run).to include_recipe("wlp::_zip_install")
    end

    it "include java recipe" do
      expect(chef_run).to include_recipe("java::default")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "install unzip package" do
      expect(chef_run).to install_package("unzip")
    end

    it "download wlp.zip" do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/wlp.zip")
    end

    it  "unzip wlp.zip" do
      expect(chef_run).to run_execute("unzip #{Chef::Config[:file_cache_path]}/wlp.zip").with(:cwd => chef_run.node["wlp"]["base_dir"], :user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  ### Install using zip
  context "zip::basic file url" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["install_method"] = "zip"
      chef_run.node.set["wlp"]["zip"]["url"] = "file:///mnt/shared/wlp.zip"
      chef_run.converge "wlp::default"
    }

    it "include zip_install" do
      expect(chef_run).to include_recipe("wlp::_zip_install")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "install unzip package" do
      expect(chef_run).to install_package("unzip")
    end

    it "download wlp.zip" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/wlp.zip")
    end

    it  "unzip wlp.zip" do
      expect(chef_run).to run_execute("unzip /mnt/shared/wlp.zip").with(:cwd => chef_run.node["wlp"]["base_dir"], :user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  # Test handling of file:// urls
  context "archive::all file url" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["archive"]["base_url"] = "file:///mnt/shared"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["archive"]["runtime"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/runtime.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extended.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["url"] = "file:///root/extras.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["install"] = true
      chef_run.converge "wlp::default"
    }

    it "include archive_install" do
      expect(chef_run).to include_recipe("wlp::_archive_install")
    end

    it "create group" do
      expect(chef_run).to create_group(chef_run.node["wlp"]["group"])
    end

    it "create user" do
      expect(chef_run).to create_user(chef_run.node["wlp"]["user"])
    end

    it "create base directory" do
      baseDir = chef_run.node["wlp"]["base_dir"]
      expect(chef_run).to create_directory(baseDir)
      dir = chef_run.directory(baseDir)
      expect(dir.owner).to eq(chef_run.node["wlp"]["user"])
      expect(dir.group).to eq(chef_run.node["wlp"]["group"])
    end

    it "download runtime.jar" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/runtime.jar")
    end

    it "download extended.jar" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/extended.jar")
    end

    it "not download extras.jar" do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/extras.jar")
    end

    it  "install runtime.jar" do
      expect(chef_run).to run_execute("java -jar /mnt/shared/runtime.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extended.jar" do
      expect(chef_run).to run_execute("java -jar /mnt/shared/extended.jar --acceptLicense #{chef_run.node["wlp"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

    it  "install extras.jar" do
      expect(chef_run).to run_execute("java -jar /root/extras.jar --acceptLicense #{chef_run.node["wlp"]["archive"]["extras"]["base_dir"]}").with(:user => chef_run.node["wlp"]["user"], :group => chef_run.node["wlp"]["group"])
    end

  end

  # test without using java cookbook
  context "archive::basic no java" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["archive"]["base_url"] = "http://example.com/"
      chef_run.node.set["wlp"]["archive"]["accept_license"] = true
      chef_run.node.set["wlp"]["archive"]["runtime"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/runtime.jar"
      chef_run.node.set["wlp"]["archive"]["extended"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extended.jar"
      chef_run.node.set["wlp"]["archive"]["extras"]["url"] = "#{chef_run.node["wlp"]["archive"]["base_url"]}/extras.jar"
      chef_run.node.set["wlp"]["install_java"] = false
      chef_run.converge "wlp::default"
    }

    it "include archive_install" do
      expect(chef_run).to include_recipe("wlp::_archive_install")
    end

    it "include java recipe" do
      expect(chef_run).not_to include_recipe("java::default")
    end
  end

 context "zip::basic no java" do
    let (:chef_run) { 
      chef_run = ChefSpec::Runner.new(:platform => "ubuntu", :version => "12.04")
      chef_run.node.set["wlp"]["install_method"] = "zip"
      chef_run.node.set["wlp"]["zip"]["url"] = "http://example.com/wlp.zip"
      chef_run.node.set["wlp"]["install_java"] = false
      chef_run.converge "wlp::default"
    }

    it "include zip_install" do
      expect(chef_run).to include_recipe("wlp::_zip_install")
    end

    it "include java recipe" do
      expect(chef_run).not_to include_recipe("java::default")
    end
  end

end


