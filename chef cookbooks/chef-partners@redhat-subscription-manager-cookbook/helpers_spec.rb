#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: 2015-2018 Chef Software, Inc.
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
require_relative '../../libraries/helpers'

class Tester
  include RhsmCookbook::RhsmHelpers
end

describe 'RhsmCookbook::RhsmHelpers' do
  let(:resource) { Tester.new }

  describe '#register_command' do
    before do
      allow(resource).to receive(:activation_keys).and_return([])
      allow(resource).to receive(:auto_attach)
    end

    context 'when activation keys exist' do
      before do
        allow(resource).to receive(:activation_keys).and_return(%w(key1 key2))
      end

      context 'when no org exists' do
        it 'raises an exception' do
          allow(resource).to receive(:organization).and_return(nil)
          expect { resource.register_command }.to raise_error(RuntimeError)
        end
      end

      context 'when an org exists' do
        it 'returns a command containing the keys and org' do
          allow(resource).to receive(:organization).and_return('myorg')

          expect(resource.register_command).to match('--activationkey=key1 --activationkey=key2 --org=myorg')
        end
      end

      context 'when auto_attach is true' do
        it 'does not return a command with --auto-attach since it is not supported with activation keys' do
          allow(resource).to receive(:organization).and_return('myorg')
          allow(resource).to receive(:auto_attach).and_return(true)

          expect(resource.register_command).not_to match('--auto-attach')
        end
      end
    end

    context 'when username and password exist' do
      before do
        allow(resource).to receive(:username).and_return('myuser')
        allow(resource).to receive(:password).and_return('mypass')
        allow(resource).to receive(:environment)
        allow(resource).to receive(:using_satellite_host?)
      end

      context 'when auto_attach is true' do
        it 'returns a command containing --auto-attach' do
          allow(resource).to receive(:auto_attach).and_return(true)

          expect(resource.register_command).to match('--auto-attach')
        end
      end

      context 'when auto_attach is false' do
        it 'returns a command that does not contain --auto-attach' do
          allow(resource).to receive(:auto_attach).and_return(false)

          expect(resource.register_command).not_to match('--auto-attach')
        end
      end

      context 'when auto_attach is nil' do
        it 'returns a command that does not contain --auto-attach' do
          allow(resource).to receive(:auto_attach).and_return(nil)

          expect(resource.register_command).not_to match('--auto-attach')
        end
      end

      context 'when environment does not exist' do
        context 'when registering to a satellite server' do
          it 'raises an exception' do
            allow(resource).to receive(:using_satellite_host?).and_return(true)
            allow(resource).to receive(:environment).and_return(nil)
            expect { resource.register_command }.to raise_error(RuntimeError)
          end
        end

        context 'when registering to RHSM proper' do
          before do
            allow(resource).to receive(:using_satellite_host?).and_return(false)
            allow(resource).to receive(:environment).and_return(nil)
          end

          it 'does not raise an exception' do
            expect { resource.register_command }.not_to raise_error
          end

          it 'returns a command containing the username and password and no environment' do
            allow(resource).to receive(:environment).and_return('myenv')
            expect(resource.register_command).to match('--username=myuser --password=mypass')
            expect(resource.register_command).not_to match('--environment')
          end
        end
      end

      context 'when an environment exists' do
        it 'returns a command containing the username, password, and environment' do
          allow(resource).to receive(:using_satellite_host?).and_return(true)
          allow(resource).to receive(:environment).and_return('myenv')
          expect(resource.register_command).to match('--username=myuser --password=mypass --environment=myenv')
        end
      end
    end

    context 'when no activation keys, username, or password exist' do
      it 'raises an exception' do
        allow(resource).to receive(:activation_keys).and_return([])
        allow(resource).to receive(:username).and_return(nil)
        allow(resource).to receive(:password).and_return(nil)

        expect { resource.register_command }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#registered_with_rhsm?' do
    let(:cmd) { double('cmd') }

    before do
      allow(Mixlib::ShellOut).to receive(:new).and_return(cmd)
      allow(cmd).to receive(:run_command)
    end

    context 'when the status is Unknown' do
      it 'returns false' do
        allow(cmd).to receive(:stdout).and_return('Overall Status: Unknown')
        expect(resource.registered_with_rhsm?).to eq(false)
      end
    end

    context 'when the status is anything else' do
      it 'returns true' do
        allow(cmd).to receive(:stdout).and_return('Overall Status: Insufficient')
        expect(resource.registered_with_rhsm?).to eq(true)
      end
    end
  end

  describe '#katello_cert_rpm_installed?' do
    let(:cmd) { double('cmd') }

    before do
      allow(Mixlib::ShellOut).to receive(:new).and_return(cmd)
      allow(cmd).to receive(:run_command)
    end

    context 'when the output contains katello-ca-consumer' do
      it 'returns true' do
        allow(cmd).to receive(:stdout).and_return('katello-ca-consumer-somehostname-1.0-1')
        expect(resource.katello_cert_rpm_installed?).to eq(true)
      end
    end

    context 'when the output does not contain katello-ca-consumer' do
      it 'returns false' do
        allow(cmd).to receive(:stdout).and_return('katello-agent-but-not-the-ca')
        expect(resource.katello_cert_rpm_installed?).to eq(false)
      end
    end
  end

  describe '#subscription_attached?' do
    let(:cmd)    { double('cmd') }
    let(:output) { 'Pool ID:    pool123' }

    before do
      allow(Mixlib::ShellOut).to receive(:new).and_return(cmd)
      allow(cmd).to receive(:run_command)
      allow(cmd).to receive(:stdout).and_return(output)
    end

    context 'when the pool provided matches the output' do
      it 'returns true' do
        expect(resource.subscription_attached?('pool123')).to eq(true)
      end
    end

    context 'when the pool provided does not match the output' do
      it 'returns false' do
        expect(resource.subscription_attached?('differentpool')).to eq(false)
      end
    end
  end

  describe '#repo_enabled?' do
    let(:cmd)    { double('cmd') }
    let(:output) { 'Repo ID:    repo123' }

    before do
      allow(Mixlib::ShellOut).to receive(:new).and_return(cmd)
      allow(cmd).to receive(:run_command)
      allow(cmd).to receive(:stdout).and_return(output)
    end

    context 'when the repo provided matches the output' do
      it 'returns true' do
        expect(resource.repo_enabled?('repo123')).to eq(true)
      end
    end

    context 'when the repo provided does not match the output' do
      it 'returns false' do
        expect(resource.repo_enabled?('differentrepo')).to eq(false)
      end
    end
  end

  describe '#serials_by_pool' do
    let(:cmd) { double('cmd') }
    let(:output) do
      <<-EOL
Key1:       value1
Pool ID:    pool1
Serial:     serial1
Key2:       value2

Key1:       value1
Pool ID:    pool2
Serial:     serial2
Key2:       value2
EOL
    end

    it 'parses the output correctly' do
      allow(Mixlib::ShellOut).to receive(:new).and_return(cmd)
      allow(cmd).to receive(:run_command)
      allow(cmd).to receive(:stdout).and_return(output)

      expect(resource.serials_by_pool['pool1']).to eq('serial1')
      expect(resource.serials_by_pool['pool2']).to eq('serial2')
    end
  end

  describe '#pool_serial' do
    let(:serials) { { 'pool1' => 'serial1', 'pool2' => 'serial2' } }

    it 'returns the serial for a given pool' do
      allow(resource).to receive(:serials_by_pool).and_return(serials)
      expect(resource.pool_serial('pool1')).to eq('serial1')
    end
  end
end
