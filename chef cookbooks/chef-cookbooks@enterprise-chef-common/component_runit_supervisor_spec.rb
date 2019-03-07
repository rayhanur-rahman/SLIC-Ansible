require 'spec_helper'

RSpec.shared_examples 'systemd create' do
  it 'renders the unit template' do
    expect(chef_run).to create_template(
      "/etc/systemd/system/#{enterprise_name}-runsvdir-start.service"
    ).with(
      owner: 'root',
      group: 'root',
      mode: '0644',
      variables: {
        install_path: '/opt/tp',
        project_name: enterprise_name,
      },
      source: 'runsvdir-start.service.erb'
    )
  end

  it 'removes unit files previously created in /usr/lib/systemd/system' do
    allow(::File).to receive(:exist?).and_call_original
    old_file = "/usr/lib/systemd/system/#{enterprise_name}-runsvdir-start.service"
    allow(::File).to receive(:exist?).with(old_file).and_return true
    expect(chef_run).to delete_file(old_file)
    expect(chef_run.file(old_file)).to notify('execute[systemctl daemon-reload]').to(:run).immediately
  end

  it 'enables the service' do
    expect(chef_run).to enable_service("#{enterprise_name}-runsvdir-start.service").with(
      provider: Chef::Provider::Service::Systemd
    )
  end

  it 'starts the service' do
    expect(chef_run).to start_service("#{enterprise_name}-runsvdir-start.service").with(
      provider: Chef::Provider::Service::Systemd
    )
  end
end

RSpec.shared_examples 'sysvinit create' do
  before :each do
    stub_command(
      "grep 'TP:123456:respawn:/opt/tp/embedded/bin/runsvdir-start' /etc/inittab"
    ).and_return false
  end

  describe 'inittab' do
    it 'echoes the svdir line to it' do
      expect(chef_run).to run_execute(
        "echo 'TP:123456:respawn:/opt/tp/embedded/bin/runsvdir-start' >> /etc/inittab"
      )
    end

    it 'notifies execute[init q]' do
      expect(chef_run.execute(
               "echo 'TP:123456:respawn:/opt/tp/embedded/bin/runsvdir-start' >> /etc/inittab"
             )).to notify('execute[init q]').to(:run).immediately
    end
  end
end

RSpec.shared_examples 'upstart create' do
  before :each do
    stub_command('initctl status opscode-runsvdir | grep start').and_return true
    stub_command("initctl status #{enterprise_name}-runsvdir | grep stop").and_return true
  end

  it 'stops the previously named service' do
    expect(chef_run).to run_execute('initctl stop opscode-runsvdir').with(
      retries: 30
    )
  end

  it 'deletes /etc/init/opscode-runsvdir.conf' do
    expect(chef_run).to delete_file '/etc/init/opscode-runsvdir.conf'
  end

  it 'renders the init template' do
    expect(chef_run).to create_template("/etc/init/#{enterprise_name}-runsvdir.conf").with(
      owner: 'root',
      group: 'root',
      mode: '0644',
      source: 'init-runsvdir.erb',
      variables: {
        install_path: '/opt/tp',
      }
    )
  end

  it 'runs the status command' do
    expect(chef_run).to run_execute("initctl status #{enterprise_name}-runsvdir").with(
      retries: 30
    )
  end

  it 'runs the start command' do
    expect(chef_run).to run_execute("initctl start #{enterprise_name}-runsvdir").with(
      retries: 30
    )
  end

  context 'when the enterprise_name is private_chef' do
    let(:enterprise_name) { 'private_chef' }

    before :each do
      stub_command('initctl status private-chef-runsvdir | grep stop').and_return true
    end

    it 'renders the init template' do
      expect(chef_run).to create_template('/etc/init/private-chef-runsvdir.conf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        source: 'init-runsvdir.erb',
        variables: {
          install_path: '/opt/tp',
        }
      )
    end

    it 'runs the status command' do
      expect(chef_run).to run_execute('initctl status private-chef-runsvdir').with(
        retries: 30
      )
    end

    it 'runs the start command' do
      expect(chef_run).to run_execute('initctl start private-chef-runsvdir').with(
        retries: 30
      )
    end
  end
end

RSpec.shared_examples 'systemd delete' do
  it 'stops the service' do
    expect(chef_run).to stop_service("#{enterprise_name}-runsvdir-start.service").with(
      provider: Chef::Provider::Service::Systemd
    )
  end

  it 'disables the service' do
    expect(chef_run).to disable_service("#{enterprise_name}-runsvdir-start.service").with(
      provider: Chef::Provider::Service::Systemd
    )
  end

  it 'deletes the unit file' do
    expect(chef_run).to delete_file(
      "/etc/systemd/system/#{enterprise_name}-runsvdir-start.service"
    )
  end
end

RSpec.shared_examples 'sysvinit delete' do
  before :each do
    stub_command(
      "grep 'TP:123456:respawn:/opt/tp/embedded/bin/runsvdir-start' /etc/inittab"
    ).and_return true
  end

  it 'deletes the line from the inittab' do
    expect(chef_run).to run_ruby_block 'remove inittab entry'
  end

  it 'notifies execute[init q]' do
    expect(chef_run.ruby_block('remove inittab entry')).to notify(
      'execute[init q]'
    ).to(:run).immediately
  end

  it 'notifies execute[pkill -HUP -P 1 runsv$]' do
    expect(chef_run.ruby_block('remove inittab entry')).to notify(
      'execute[pkill -HUP -P 1 runsv$]'
    ).to(:run).immediately
  end
end

RSpec.shared_examples 'upstart delete' do
  it 'stops the service' do
    expect(chef_run).to stop_service("#{enterprise_name}-runsvdir").with(
      provider: Chef::Provider::Service::Upstart
    )
  end

  it 'disables the service' do
    expect(chef_run).to disable_service("#{enterprise_name}-runsvdir").with(
      provider: Chef::Provider::Service::Upstart
    )
  end

  it 'deletes the init file' do
    expect(chef_run).to delete_file("/etc/init/#{enterprise_name}-runsvdir.conf")
  end

  context 'when the enterprise_name is private_chef' do
    let(:enterprise_name) { 'private_chef' }

    it 'stops the service' do
      expect(chef_run).to stop_service('private-chef-runsvdir').with(
        provider: Chef::Provider::Service::Upstart
      )
    end

    it 'disables the service' do
      expect(chef_run).to disable_service('private-chef-runsvdir').with(
        provider: Chef::Provider::Service::Upstart
      )
    end

    it 'deletes the init file' do
      expect(chef_run).to delete_file('/etc/init/private-chef-runsvdir.conf')
    end
  end
end

describe 'enterprise_test::component_runit_supervisor_create' do
  let(:runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', step_into: ['component_runit_supervisor'])
  end
  subject(:chef_run) { runner.converge(described_recipe) }
  let(:enterprise_name) { 'testproject' }

  before :each do
    # Set the node project_name
    runner.node.normal['enterprise']['name'] = enterprise_name
  end

  describe 'component_runit_supervisor resource' do
    describe 'action :create' do
      context 'when on Amazon Linux' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'amazon', version: '2017.03',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart create'
      end

      context 'when on Debian' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'debian', version: '7.11',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit create'
      end

      context 'when on Fedora' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'fedora', version: '25', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd create'
      end

      context 'when on RHEL 5' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '5.11',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit create'
      end

      context 'when on RHEL 6' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '6.9',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart create'
      end

      context 'when on RHEL 7 with systemd' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '7.3.1611', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd create'
      end

      context 'when on SuSE 11' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'suse', version: '11.4',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit create'
      end

      context 'when on SuSE 12 with systemd' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'suse', version: '12.1', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd create'
      end

      context 'when on Ubuntu' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'ubuntu', version: '14.04',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart create'
      end
    end
  end
end

describe 'enterprise_test::component_runit_supervisor_delete' do
  let(:runner) do
    ChefSpec::SoloRunner.new step_into: ['component_runit_supervisor']
  end
  subject(:chef_run) { runner.converge(described_recipe) }
  let(:enterprise_name) { 'testproject' }

  before :each do
    # Set the node project_name
    runner.node.normal['enterprise']['name'] = enterprise_name
  end

  describe 'component_runit_supervisor resource' do
    describe 'action :delete' do
      context 'when on Amazon Linux' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'amazon', version: '2017.03',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart delete'
      end

      context 'when on Debian' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'debian', version: '7.11',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit delete'
      end

      context 'when on Fedora' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'fedora', version: '25', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd delete'
      end

      context 'when on RHEL 5' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '5.11',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit delete'
      end

      context 'when on RHEL 6' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '6.9',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart delete'
      end

      context 'when on RHEL 7 with systemd' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'centos', version: '7.3.1611', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd delete'
      end

      context 'when on SuSE 11' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'suse', version: '11.4',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'sysvinit delete'
      end

      context 'when on SuSE 12' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'suse', version: '12.2', step_into: ['component_runit_supervisor'] do |node|
            node.default['init_package'] = 'systemd'
          end
        end

        it_behaves_like 'systemd delete'
      end

      context 'when on Ubuntu' do
        let(:runner) do
          ChefSpec::SoloRunner.new platform: 'ubuntu', version: '14.04',
                                   step_into: ['component_runit_supervisor']
        end

        it_behaves_like 'upstart delete'
      end
    end
  end
end
