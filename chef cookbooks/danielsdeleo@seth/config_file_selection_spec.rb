#
# Author:: Nicolas Vinot (<aeris@imirhil.fr>)
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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'tmpdir'

describe Seth::ceth do

  let(:missing_config_fetcher) do
    double(Seth::ConfigFetcher, :config_missing? => true)
  end

  let(:available_config_fetcher) do
    double(Seth::ConfigFetcher, :config_missing? => false,
                                :read_config => "")
  end

  def have_config_file(path)
    Seth::ConfigFetcher.should_receive(:new).at_least(1).times.with(path, nil).and_return(available_config_fetcher)
  end

  before do
    # Make sure tests can run when HOME is not set...
    @original_home = ENV["HOME"]
    ENV["HOME"] = Dir.tmpdir
  end

  after do
    ENV["HOME"] = @original_home
  end

  before :each do
    Seth::Config.stub(:from_file).and_return(true)
    Seth::ConfigFetcher.stub(:new).and_return(missing_config_fetcher)
  end

  it "configure ceth from ceth_HOME env variable" do
    env_config = File.expand_path(File.join(Dir.tmpdir, 'ceth.rb'))
    have_config_file(env_config)

    ENV['ceth_HOME'] = Dir.tmpdir
    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == env_config
  end

   it "configure ceth from PWD" do
    pwd_config = "#{Dir.pwd}/ceth.rb"
    have_config_file(pwd_config)

    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == pwd_config
  end

  it "configure ceth from UPWARD" do
    upward_dir = File.expand_path "#{Dir.pwd}/.seth"
    upward_config = File.expand_path "#{upward_dir}/ceth.rb"
    have_config_file(upward_config)
    Seth::ceth.stub(:seth_config_dir).and_return(upward_dir)

    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == upward_config
  end

  it "configure ceth from HOME" do
    home_config = File.expand_path(File.join("#{ENV['HOME']}", "/.seth/ceth.rb"))
    have_config_file(home_config)

    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == home_config
  end

  it "configure ceth from nothing" do
    ::File.stub(:exist?).and_return(false)
    @ceth = Seth::ceth.new
    @ceth.ui.should_receive(:warn).with("No ceth configuration file found")
    @ceth.configure_seth
    @ceth.config[:config_file].should be_nil
  end

  it "configure ceth precedence" do
    env_config = File.join(Dir.tmpdir, 'ceth.rb')
    pwd_config = "#{Dir.pwd}/ceth.rb"
    upward_dir = File.expand_path "#{Dir.pwd}/.seth"
    upward_config = File.expand_path "#{upward_dir}/ceth.rb"
    home_config = File.expand_path(File.join("#{ENV['HOME']}", "/.seth/ceth.rb"))
    configs = [ env_config, pwd_config, upward_config, home_config ]

    Seth::ceth.stub(:seth_config_dir).and_return(upward_dir)
    ENV['ceth_HOME'] = Dir.tmpdir

    @ceth = Seth::ceth.new

    @ceth.configure_seth
    @ceth.config[:config_file].should be_nil

    have_config_file(home_config)
    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == home_config

    have_config_file(upward_config)
    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == upward_config

    have_config_file(pwd_config)
    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == pwd_config

    have_config_file(env_config)
    @ceth = Seth::ceth.new
    @ceth.configure_seth
    @ceth.config[:config_file].should == env_config
  end
end
