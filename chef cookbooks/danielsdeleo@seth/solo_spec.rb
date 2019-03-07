#
# Author:: AJ Christensen (<aj@junglist.gen.nz>)
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

require 'spec_helper'

describe Seth::Application::Solo do
  before do
    Kernel.stub(:trap).and_return(:ok)
    @app = Seth::Application::Solo.new
    @app.stub(:configure_opt_parser).and_return(true)
    @app.stub(:configure_seth).and_return(true)
    @app.stub(:configure_logging).and_return(true)
    @app.stub(:trap)
    Seth::Config[:recipe_url] = false
    Seth::Config[:json_attribs] = false
    Seth::Config[:solo] = true
  end

  describe "configuring the application" do
    it "should set solo mode to true" do
      @app.reconfigure
      Seth::Config[:solo].should be_true
    end

    describe "when in daemonized mode and no interval has been set" do
      before do
        Seth::Config[:daemonize] = true
      end

      it "should set the interval to 1800" do
        Seth::Config[:interval] = nil
        @app.reconfigure
        Seth::Config[:interval].should == 1800
      end
    end

    describe "when the json_attribs configuration option is specified" do

      let(:json_attribs) { {"a" => "b"} }
      let(:config_fetcher) { double(Seth::ConfigFetcher, :fetch_json => json_attribs) }
      let(:json_source) { "https://foo.com/foo.json" }

      before do
        Seth::Config[:json_attribs] = json_source
        Seth::ConfigFetcher.should_receive(:new).with(json_source).
          and_return(config_fetcher)
      end

      it "reads the JSON attributes from the specified source" do
        @app.reconfigure
        @app.seth_client_json.should == json_attribs
      end
    end



    describe "when the recipe_url configuration option is specified" do
      before do
        Seth::Config[:cookbook_path] = "#{Dir.tmpdir}/seth-solo/cookbooks"
        Seth::Config[:recipe_url] = "http://junglist.gen.nz/recipes.tgz"
        FileUtils.stub(:mkdir_p).and_return(true)
        @tarfile = StringIO.new("remote_tarball_content")
        @app.stub(:open).with("http://junglist.gen.nz/recipes.tgz").and_yield(@tarfile)

        @target_file = StringIO.new
        File.stub(:open).with("#{Dir.tmpdir}/seth-solo/recipes.tgz", "wb").and_yield(@target_file)

        Seth::Mixin::Command.stub(:run_command).and_return(true)
      end

      it "should create the recipes path based on the parent of the cookbook path" do
        FileUtils.should_receive(:mkdir_p).with("#{Dir.tmpdir}/seth-solo").and_return(true)
        @app.reconfigure
      end

      it "should download the recipes" do
        @app.should_receive(:open).with("http://junglist.gen.nz/recipes.tgz").and_yield(@tarfile)
        @app.reconfigure
      end

      it "should write the recipes to the target path" do
        @app.reconfigure
        @target_file.string.should == "remote_tarball_content"
      end

      it "should untar the target file to the parent of the cookbook path" do
        Seth::Mixin::Command.should_receive(:run_command).with({:command => "tar zxvf #{Dir.tmpdir}/seth-solo/recipes.tgz -C #{Dir.tmpdir}/seth-solo"}).and_return(true)
        @app.reconfigure
      end
    end
  end


  describe "after the application has been configured" do
    before do
      Seth::Config[:solo] = true

      Seth::Daemon.stub(:change_privilege)
      @seth_client = double("Seth::Client")
      Seth::Client.stub(:new).and_return(@seth_client)
      @app = Seth::Application::Solo.new
      # this is all stuff the reconfigure method needs
      @app.stub(:configure_opt_parser).and_return(true)
      @app.stub(:configure_seth).and_return(true)
      @app.stub(:configure_logging).and_return(true)
    end

    it "should change privileges" do
      Seth::Daemon.should_receive(:change_privilege).and_return(true)
      @app.setup_application
    end
  end

end

