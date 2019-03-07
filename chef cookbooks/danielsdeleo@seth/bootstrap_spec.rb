#
# Author:: Ian Meyer (<ianmmeyer@gmail.com>)
# Copyright:: Copyright (c) 2010 Ian Meyer
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

Seth::ceth::Bootstrap.load_deps
require 'net/ssh'

describe Seth::ceth::Bootstrap do
  before(:each) do
    Seth::Log.logger = Logger.new(StringIO.new)
    @ceth = Seth::ceth::Bootstrap.new
    # Merge default settings in.
    @ceth.merge_configs
    @ceth.config[:template_file] = File.expand_path(File.join(seth_SPEC_DATA, "bootstrap", "test.erb"))
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
    @stderr = StringIO.new
    @ceth.ui.stub(:stderr).and_return(@stderr)
  end

  it "should return a name of default bootstrap template" do
    @ceth.find_template.should be_a_kind_of(String)
  end

  it "should error if template can not be found" do
    @ceth.config[:template_file] = false
    @ceth.config[:distro] = 'penultimate'
    lambda { @ceth.find_template }.should raise_error
  end

  it "should look for templates early in the run" do
    File.stub(:exists?).and_return(true)
    @ceth.name_args = ['shatner']
    @ceth.stub(:read_template).and_return("")
    @ceth.stub(:ceth_ssh).and_return(true)
    @ceth_ssh = @ceth.ceth_ssh
    @ceth.should_receive(:find_template).ordered
    @ceth.should_receive(:ceth_ssh).ordered
    @ceth_ssh.should_receive(:run) # rspec appears to keep order per object
    @ceth.run
  end

  it "should load the specified template" do
    @ceth.config[:distro] = 'fedora13-gems'
    lambda { @ceth.find_template }.should_not raise_error
  end

  it "should load the specified template from a Ruby gem" do
    @ceth.config[:template_file] = false
    Gem.stub(:find_files).and_return(["/Users/schisamo/.rvm/gems/ruby-1.9.2-p180@seth-0.10/gems/ceth-windows-0.5.4/lib/seth/ceth/bootstrap/fake-bootstrap-template.erb"])
    File.stub(:exists?).and_return(true)
    IO.stub(:read).and_return('random content')
    @ceth.config[:distro] = 'fake-bootstrap-template'
    lambda { @ceth.find_template }.should_not raise_error
  end

  it "should return an empty run_list" do
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.render_template(template_string).should == '{"run_list":[]}'
  end

  it "should have role[base] in the run_list" do
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.parse_options(["-r","role[base]"])
    @ceth.render_template(template_string).should == '{"run_list":["role[base]"]}'
  end

  it "should have role[base] and recipe[cupcakes] in the run_list" do
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.parse_options(["-r", "role[base],recipe[cupcakes]"])
    @ceth.render_template(template_string).should == '{"run_list":["role[base]","recipe[cupcakes]"]}'
  end

  it "should have foo => {bar => baz} in the first_boot" do
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.parse_options(["-j", '{"foo":{"bar":"baz"}}'])
    expected_hash = Yajl::Parser.new.parse('{"foo":{"bar":"baz"},"run_list":[]}')
    actual_hash = Yajl::Parser.new.parse(@ceth.render_template(template_string))
    actual_hash.should == expected_hash
  end

  it "should create a hint file when told to" do
    @ceth.config[:template_file] = File.expand_path(File.join(seth_SPEC_DATA, "bootstrap", "test-hints.erb"))
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.parse_options(["--hint", "openstack"])
    @ceth.render_template(template_string).should match /\/etc\/seth\/ohai\/hints\/openstack.json/
  end

  it "should populate a hint file with JSON when given a file to read" do
    @ceth.stub(:find_template).and_return(true)
    @ceth.config[:template_file] = File.expand_path(File.join(seth_SPEC_DATA, "bootstrap", "test-hints.erb"))
    ::File.stub(:read).and_return('{ "foo" : "bar" }')
    @ceth.instance_variable_set("@template_file", @ceth.config[:template_file])
    template_string = @ceth.read_template
    @ceth.stub(:read_template).and_return('{ "foo" : "bar" }')
    @ceth.parse_options(["--hint", "openstack=hints/openstack.json"])
    @ceth.render_template(template_string).should match /\{\"foo\":\"bar\"\}/
  end

  it "should take the node name from ARGV" do
    @ceth.name_args = ['barf']
    @ceth.name_args.first.should == "barf"
  end

  describe "specifying no_proxy with various entries" do
    subject(:ceth) do
      k = described_class.new
      k.instance_variable_set("@template_file", template_file)
      k.parse_options(options)
      k.merge_configs
      k
    end

    # Include a data bag secret in the options to prevent Bootstrap from
    # attempting to access /etc/seth/encrypted_data_bag_secret, which
    # can fail when the file exists but can't be accessed by the user
    # running the tests.
    let(:options){ ["--bootstrap-no-proxy", setting, "-s", "foo"] }
    let(:template_file) { File.expand_path(File.join(seth_SPEC_DATA, "bootstrap", "no_proxy.erb")) }
    let(:rendered_template) do
      template_string = ceth.read_template
      ceth.render_template(template_string)
    end

    context "via --bootstrap-no-proxy" do
      let(:setting) { "api.opscode.com" }

      it "renders the client.rb with a single FQDN no_proxy entry" do
        rendered_template.should match(%r{.*no_proxy\s*"api.opscode.com".*})
      end
    end

    context "via --bootstrap-no-proxy multiple" do
      let(:setting) { "api.opscode.com,172.16.10.*" }

      it "renders the client.rb with comma-separated FQDN and wildcard IP address no_proxy entries" do
        rendered_template.should match(%r{.*no_proxy\s*"api.opscode.com,172.16.10.\*".*})
      end
    end
  end

  describe "specifying the encrypted data bag secret key" do
    subject(:ceth) { described_class.new }
    let(:secret) { "supersekret" }
    let(:secret_file) { File.join(seth_SPEC_DATA, 'bootstrap', 'encrypted_data_bag_secret') }
    let(:options) { [] }
    let(:template_file) { File.expand_path(File.join(seth_SPEC_DATA, "bootstrap", "secret.erb")) }
    let(:rendered_template) do
      ceth.instance_variable_set("@template_file", template_file)
      ceth.parse_options(options)
      template_string = ceth.read_template
      ceth.render_template(template_string)
    end

    context "via --secret" do
      let(:options){ ["--secret", secret] }

      it "creates a secret file" do
        rendered_template.should match(%r{#{secret}})
      end

      it "renders the client.rb with an encrypted_data_bag_secret entry" do
        rendered_template.should match(%r{encrypted_data_bag_secret\s*"/etc/seth/encrypted_data_bag_secret"})
      end
    end

    context "via --secret-file" do
      let(:options) { ["--secret-file", secret_file] }
      let(:secret) { IO.read(secret_file) }

      it "creates a secret file" do
        rendered_template.should match(%r{#{secret}})
      end

      it "renders the client.rb with an encrypted_data_bag_secret entry" do
        rendered_template.should match(%r{encrypted_data_bag_secret\s*"/etc/seth/encrypted_data_bag_secret"})
      end
    end

    context "via Seth::Config[:encrypted_data_bag_secret]" do
      before(:each) { Seth::Config[:encrypted_data_bag_secret] = secret_file }
      let(:secret) { IO.read(secret_file) }

      it "creates a secret file" do
        rendered_template.should match(%r{#{secret}})
      end

      it "renders the client.rb with an encrypted_data_bag_secret entry" do
        rendered_template.should match(%r{encrypted_data_bag_secret\s*"/etc/seth/encrypted_data_bag_secret"})
      end
    end
  end

  describe "when configuring the underlying ceth ssh command" do
    context "from the command line" do
      before do
        @ceth.name_args = ["foo.example.com"]
        @ceth.config[:ssh_user]      = "rooty"
        @ceth.config[:ssh_port]      = "4001"
        @ceth.config[:ssh_password]  = "open_sesame"
        Seth::Config[:ceth][:ssh_user] = nil
        Seth::Config[:ceth][:ssh_port] = nil
        @ceth.config[:forward_agent] = true
        @ceth.config[:identity_file] = "~/.ssh/me.rsa"
        @ceth.stub(:read_template).and_return("")
        @ceth_ssh = @ceth.ceth_ssh
      end

      it "configures the hostname" do
        @ceth_ssh.name_args.first.should == "foo.example.com"
      end

      it "configures the ssh user" do
        @ceth_ssh.config[:ssh_user].should == 'rooty'
      end

      it "configures the ssh password" do
        @ceth_ssh.config[:ssh_password].should == 'open_sesame'
      end

      it "configures the ssh port" do
        @ceth_ssh.config[:ssh_port].should == '4001'
      end

      it "configures the ssh agent forwarding" do
        @ceth_ssh.config[:forward_agent].should == true
      end

      it "configures the ssh identity file" do
        @ceth_ssh.config[:identity_file].should == '~/.ssh/me.rsa'
      end
    end
    context "validating use_sudo_password" do
      before do
        @ceth.config[:distro] = "ubuntu"
        @ceth.config[:ssh_password] = "password"
        @ceth.stub(:read_template).and_return(IO.read(@ceth.find_template).chomp)
      end

      it "use_sudo_password contains description and long params for help" do
        @ceth.options.should have_key(:use_sudo_password) \
          and @ceth.options[:use_sudo_password][:description].to_s.should_not == ''\
          and @ceth.options[:use_sudo_password][:long].to_s.should_not == ''
      end

      it "uses the password from --ssh-password for sudo when --use-sudo-password is set" do
        @ceth.config[:use_sudo] = true
        @ceth.config[:use_sudo_password] = true
        @ceth.ssh_command.should include("echo \'#{@ceth.config[:ssh_password]}\' | sudo -S")
      end

      it "should not honor --use-sudo-password when --use-sudo is not set" do
        @ceth.config[:use_sudo] = false
        @ceth.config[:use_sudo_password] = true
        @ceth.ssh_command.should_not include("echo #{@ceth.config[:ssh_password]} | sudo -S")
      end
    end
    context "from the ceth config file" do
      before do
        @ceth.name_args = ["config.example.com"]
        @ceth.config[:ssh_user] = nil
        @ceth.config[:ssh_port] = nil
        @ceth.config[:ssh_gateway] = nil
        @ceth.config[:forward_agent] = nil
        @ceth.config[:identity_file] = nil
        @ceth.config[:host_key_verify] = nil
        Seth::Config[:ceth][:ssh_user] = "curiosity"
        Seth::Config[:ceth][:ssh_port] = "2430"
        Seth::Config[:ceth][:forward_agent] = true
        Seth::Config[:ceth][:identity_file] = "~/.ssh/you.rsa"
        Seth::Config[:ceth][:ssh_gateway] = "towel.blinkenlights.nl"
        Seth::Config[:ceth][:host_key_verify] = true
        @ceth.stub(:read_template).and_return("")
        @ceth_ssh = @ceth.ceth_ssh
      end

      it "configures the ssh user" do
        @ceth_ssh.config[:ssh_user].should == 'curiosity'
      end

      it "configures the ssh port" do
        @ceth_ssh.config[:ssh_port].should == '2430'
      end

      it "configures the ssh agent forwarding" do
        @ceth_ssh.config[:forward_agent].should == true
      end

      it "configures the ssh identity file" do
        @ceth_ssh.config[:identity_file].should == '~/.ssh/you.rsa'
      end

      it "configures the ssh gateway" do
        @ceth_ssh.config[:ssh_gateway].should == 'towel.blinkenlights.nl'
      end

      it "configures the host key verify mode" do
        @ceth_ssh.config[:host_key_verify].should == true
      end
    end

    describe "when falling back to password auth when host key auth fails" do
      before do
        @ceth.name_args = ["foo.example.com"]
        @ceth.config[:ssh_user]      = "rooty"
        @ceth.config[:identity_file] = "~/.ssh/me.rsa"
        @ceth.stub(:read_template).and_return("")
        @ceth_ssh = @ceth.ceth_ssh
      end

      it "prompts the user for a password " do
        @ceth.stub(:ceth_ssh).and_return(@ceth_ssh)
        @ceth_ssh.stub(:get_password).and_return('typed_in_password')
        alternate_ceth_ssh = @ceth.ceth_ssh_with_password_auth
        alternate_ceth_ssh.config[:ssh_password].should == 'typed_in_password'
      end

      it "configures ceth not to use the identity file that didn't work previously" do
        @ceth.stub(:ceth_ssh).and_return(@ceth_ssh)
        @ceth_ssh.stub(:get_password).and_return('typed_in_password')
        alternate_ceth_ssh = @ceth.ceth_ssh_with_password_auth
        alternate_ceth_ssh.config[:identity_file].should be_nil
      end
    end
  end

  describe "when running the bootstrap" do
    before do
      @ceth.name_args = ["foo.example.com"]
      @ceth.config[:ssh_user]      = "rooty"
      @ceth.config[:identity_file] = "~/.ssh/me.rsa"
      @ceth.stub(:read_template).and_return("")
      @ceth_ssh = @ceth.ceth_ssh
      @ceth.stub(:ceth_ssh).and_return(@ceth_ssh)
    end

    it "verifies that a server to bootstrap was given as a command line arg" do
      @ceth.name_args = nil
      lambda { @ceth.run }.should raise_error(SystemExit)
      @stderr.string.should match /ERROR:.+FQDN or ip/
    end

    it "configures the underlying ssh command and then runs it" do
      @ceth_ssh.should_receive(:run)
      @ceth.run
    end

    it "falls back to password based auth when auth fails the first time" do
      @ceth.stub(:puts)

      @fallback_ceth_ssh = @ceth_ssh.dup
      @ceth_ssh.should_receive(:run).and_raise(Net::SSH::AuthenticationFailed.new("no ssh for you"))
      @ceth.stub(:ceth_ssh_with_password_auth).and_return(@fallback_ceth_ssh)
      @fallback_ceth_ssh.should_receive(:run)
      @ceth.run
    end

    it "raises the exception if config[:ssh_password] is set and an authentication exception is raised" do
      @ceth.config[:ssh_password] = "password"
      @ceth_ssh.should_receive(:run).and_raise(Net::SSH::AuthenticationFailed)
      lambda { @ceth.run }.should raise_error(Net::SSH::AuthenticationFailed)
    end

    context "Seth::Config[:encrypted_data_bag_secret] is set" do
      let(:secret_file) { File.join(seth_SPEC_DATA, 'bootstrap', 'encrypted_data_bag_secret') }
      before { Seth::Config[:encrypted_data_bag_secret] = secret_file }

      it "warns the configuration option is deprecated" do
        @ceth_ssh.should_receive(:run)
        @ceth.ui.should_receive(:warn).at_least(3).times
        @ceth.run
      end
    end

  end

end
