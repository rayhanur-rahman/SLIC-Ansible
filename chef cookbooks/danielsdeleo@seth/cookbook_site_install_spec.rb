#
# Author:: Steven Danna (<steve@opscode.com>)
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Seth::ceth::CookbookSiteInstall do
  before(:each) do
    require 'seth/ceth/core/cookbook_scm_repo'
    @stdout = StringIO.new
    @ceth = Seth::ceth::CookbookSiteInstall.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
    @ceth.config = {}
    if Seth::Platform.windows?
      @install_path = 'C:/tmp/seth'
    else
      @install_path = '/var/tmp/seth'
    end
    @ceth.config[:cookbook_path] = [ @install_path ]

    @stdout = StringIO.new
    @stderr = StringIO.new
    @ceth.stub(:stderr).and_return(@stdout)
    @ceth.stub(:stdout).and_return(@stdout)

    #Assume all external commands would have succeed. :(
    File.stub(:unlink)
    File.stub(:rmtree)
    @ceth.stub(:shell_out!).and_return(true)

    #CookbookSiteDownload Stup
    @downloader = {}
    @ceth.stub(:download_cookbook_to).and_return(@downloader)
    @downloader.stub(:version).and_return do
      if @ceth.name_args.size == 2
        @ceth.name_args[1]
      else
        "0.3.0"
      end
    end

    #Stubs for CookbookSCMRepo
    @repo = double(:sanity_check => true, :reset_to_default_state => true,
                 :prepare_to_import => true, :finalize_updates_to => true,
                 :merge_updates_from => true)
    Seth::ceth::CookbookSCMRepo.stub(:new).and_return(@repo)
  end


  describe "run" do
    it "should return an error if a cookbook name is not provided" do
      @ceth.name_args = []
      @ceth.ui.should_receive(:error).with("Please specify a cookbook to download and install.")
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    it "should return an error if more than two arguments are given" do
      @ceth.name_args = ["foo", "bar", "baz"]
      @ceth.ui.should_receive(:error).with("Installing multiple cookbooks at once is not supported.")
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    it "should return an error if the second argument is not a version" do
      @ceth.name_args = ["getting-started", "1pass"]
      @ceth.ui.should_receive(:error).with("Installing multiple cookbooks at once is not supported.")
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    it "should return an error if the second argument is a four-digit version" do
      @ceth.name_args = ["getting-started", "0.0.0.1"]
      @ceth.ui.should_receive(:error).with("Installing multiple cookbooks at once is not supported.")
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    it "should return an error if the second argument is a one-digit version" do
      @ceth.name_args = ["getting-started", "1"]
      @ceth.ui.should_receive(:error).with("Installing multiple cookbooks at once is not supported.")
      lambda { @ceth.run }.should raise_error(SystemExit)
    end

    it "should install the specified version if second argument is a three-digit version" do
      @ceth.name_args = ["getting-started", "0.1.0"]
      @ceth.config[:no_deps] = true
      upstream_file = File.join(@install_path, "getting-started.tar.gz")
      @ceth.should_receive(:download_cookbook_to).with(upstream_file)
      @ceth.should_receive(:extract_cookbook).with(upstream_file, "0.1.0")
      @ceth.should_receive(:clear_existing_files).with(File.join(@install_path, "getting-started"))
      @repo.should_receive(:merge_updates_from).with("getting-started", "0.1.0")
      @ceth.run
    end

    it "should install the specified version if second argument is a two-digit version" do
      @ceth.name_args = ["getting-started", "0.1"]
      @ceth.config[:no_deps] = true
      upstream_file = File.join(@install_path, "getting-started.tar.gz")
      @ceth.should_receive(:download_cookbook_to).with(upstream_file)
      @ceth.should_receive(:extract_cookbook).with(upstream_file, "0.1")
      @ceth.should_receive(:clear_existing_files).with(File.join(@install_path, "getting-started"))
      @repo.should_receive(:merge_updates_from).with("getting-started", "0.1")
      @ceth.run
    end

    it "should install the latest version if only a cookbook name is given" do
      @ceth.name_args = ["getting-started"]
      @ceth.config[:no_deps] = true
      upstream_file = File.join(@install_path, "getting-started.tar.gz")
      @ceth.should_receive(:download_cookbook_to).with(upstream_file)
      @ceth.should_receive(:extract_cookbook).with(upstream_file, "0.3.0")
      @ceth.should_receive(:clear_existing_files).with(File.join(@install_path, "getting-started"))
      @repo.should_receive(:merge_updates_from).with("getting-started", "0.3.0")
      @ceth.run
    end

    it "should not create/reset git branches if use_current_branch is set" do
      @ceth.name_args = ["getting-started"]
      @ceth.config[:use_current_branch] = true
      @ceth.config[:no_deps] = true
      upstream_file = File.join(@install_path, "getting-started.tar.gz")
      @repo.should_not_receive(:prepare_to_import)
      @repo.should_not_receive(:reset_to_default_state)
      @ceth.run
    end

    it "should not raise an error if cookbook_path is a string" do
      @ceth.config[:cookbook_path] = @install_path
      @ceth.config[:no_deps] = true
      @ceth.name_args = ["getting-started"]
      upstream_file = File.join(@install_path, "getting-started.tar.gz")
      @ceth.should_receive(:download_cookbook_to).with(upstream_file)
      @ceth.should_receive(:extract_cookbook).with(upstream_file, "0.3.0")
      @ceth.should_receive(:clear_existing_files).with(File.join(@install_path, "getting-started"))
      @repo.should_receive(:merge_updates_from).with("getting-started", "0.3.0")
      lambda { @ceth.run }.should_not raise_error
    end
  end
end
