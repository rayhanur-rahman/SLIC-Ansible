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

describe 'rhsm_test::unit' do
  describe 'rhsm_register' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        file_cache_path: '/tmp/chefspec',
        step_into: 'rhsm_register'
      ).converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?)
    end

    describe 'fetching the cert RPM' do
      let(:remote_file) { chef_run.remote_file('/tmp/chefspec/katello-package.rpm') }

      context 'when host is not registered' do
        before do
          allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(false)
        end

        context 'when satellite host is nil' do
          it 'does not fetch the katello RPM' do
            allow_any_instance_of(Chef::Resource).to receive(:satellite_host).and_return(nil)
            expect(chef_run).not_to create_remote_file('/tmp/chefspec/katello-package.rpm')
          end
        end

        context 'when satellite host is provided' do
          before do
            allow_any_instance_of(Chef::Resource).to receive(:satellite_host).and_return('mysatellite')
          end

          context 'when the cert RPM is not yet installed' do
            before do
              allow_any_instance_of(Chef::Resource).to receive(:katello_cert_rpm_installed?).and_return(false)
            end

            it 'fetches the cert' do
              expect(chef_run).to create_remote_file('/tmp/chefspec/katello-package.rpm')
            end

            it 'installs the cert' do
              expect(remote_file).to notify('yum_package[katello-ca-consumer-latest]').to(:install)
            end
          end

          context 'when the cert RPM is already installed' do
            it 'does not fetch and install the cert' do
              allow_any_instance_of(Chef::Resource).to receive(:katello_cert_rpm_installed?).and_return(true)
              expect(chef_run).not_to create_remote_file('/tmp/chefspec/katello-package.rpm')
            end
          end
        end
      end

      context 'when the host is registered' do
        it 'does not fetch and install the cert' do
          allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(true)
          expect(chef_run).not_to create_remote_file('/tmp/chefspec/katello-package.rpm')
        end
      end
    end

    describe 'deleting the fetched package' do
      it 'deletes the katello cert and config RPM file' do
        expect(chef_run).to delete_file('/tmp/chefspec/katello-package.rpm')
      end
    end

    describe 'registering to RHSM' do
      context 'when host is not registered' do
        it 'registers the host' do
          allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(false)
          allow_any_instance_of(Chef::Resource).to receive(:register_command).and_return('register-command')
          expect(chef_run).to run_execute('register-command')
        end
      end

      context 'when host is registered' do
        it 'does not register the host' do
          allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(true)
          allow_any_instance_of(Chef::Resource).to receive(:register_command).and_return('register-command')
          expect(chef_run).not_to run_execute('register-command')
        end
      end
    end

    describe 'installing the katello agent' do
      context 'when installation of the agent is enabled' do
        it 'installs the agent' do
          expect(chef_run).to install_yum_package('katello-agent')
        end
      end

      context 'when installation of the agent is disabled' do
        it 'does not install the agent' do
          allow_any_instance_of(Chef::Resource).to receive(:install_katello_agent).and_return(false)
          expect(chef_run).to_not install_yum_package('katello-agent')
        end
      end
    end
  end

  context 'rhsm_subscription' do
    before(:each) do
      allow_any_instance_of(Chef::Resource).to receive(:pool_serial)
      allow_any_instance_of(Chef::Resource).to receive(:subscription_attached?)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'rhsm_subscription'
      ).converge(described_recipe)
    end

    context 'when attaching a subscription' do
      context 'when the subscription is not attached' do
        it 'runs the subscription attach command' do
          allow_any_instance_of(Chef::Resource).to receive(:subscription_attached?).with('pool_to_add').and_return(false)
          expect(chef_run).to run_execute('subscription-manager attach --pool=pool_to_add')
        end
      end

      context 'when the subscription is already attached' do
        it 'does not run the subscription attach command' do
          allow_any_instance_of(Chef::Resource).to receive(:subscription_attached?).with('pool_to_add').and_return(true)
          expect(chef_run).not_to run_execute('subscription-manager attach --pool=pool_to_add')
        end
      end
    end

    context 'when removing a subscription' do
      before(:each) do
        allow_any_instance_of(Chef::Resource).to receive(:pool_serial).with('pool_to_remove').and_return('serial123')
      end

      context 'when the subscription is attached' do
        it 'runs the subscription remove command' do
          allow_any_instance_of(Chef::Resource).to receive(:subscription_attached?).with('pool_to_remove').and_return(true)
          expect(chef_run).to run_execute('subscription-manager remove --serial=serial123')
        end
      end

      context 'when the subscription is not attached' do
        it 'does not run the subscription remove command' do
          allow_any_instance_of(Chef::Resource).to receive(:subscription_attached?).with('pool_to_remove').and_return(false)
          expect(chef_run).not_to run_execute('subscription-manager remove --serial=serial123')
        end
      end
    end
  end

  context 'rhsm_repo' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'rhsm_repo'
      ).converge(described_recipe)
    end

    before(:each) do
      allow_any_instance_of(Chef::Resource).to receive(:repo_enabled?)
    end

    context 'when enabling a repo' do
      context 'when the repo is not enabled' do
        it 'runs the repo enable command' do
          allow_any_instance_of(Chef::Resource).to receive(:repo_enabled?).with('repo_to_add').and_return(false)
          expect(chef_run).to run_execute('subscription-manager repos --enable=repo_to_add')
        end
      end

      context 'when the repo is already enabled' do
        it 'does not run the repo enable command' do
          allow_any_instance_of(Chef::Resource).to receive(:repo_enabled?).with('repo_to_add').and_return(true)
          expect(chef_run).not_to run_execute('subscription-manager repos --enable=repo_to_add')
        end
      end
    end

    context 'when disabling a repo' do
      context 'when the repo is enabled' do
        it 'runs the repo disable command' do
          allow_any_instance_of(Chef::Resource).to receive(:repo_enabled?).with('repo_to_remove').and_return(true)
          expect(chef_run).to run_execute('subscription-manager repos --disable=repo_to_remove')
        end
      end

      context 'when the repo is already disabled' do
        it 'does not run the repo disable command' do
          allow_any_instance_of(Chef::Resource).to receive(:repo_enabled?).with('repo_to_remove').and_return(false)
          expect(chef_run).not_to run_execute('subscription-manager repos --disable=repo_to_remove')
        end
      end
    end
  end

  context 'rhsm_errata' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'rhsm_errata'
      ).converge(described_recipe)
    end

    it 'runs the correct yum update command' do
      expect(chef_run).to run_execute('yum update --advisory errata1 -y')
    end
  end

  context 'when the host is rhel6' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        platform: 'redhat', version: '6.9',
        step_into: 'rhsm_errata_level'
      ).converge(described_recipe)
    end

    it 'installs the yum-plugin-security package' do
      expect(chef_run).to install_yum_package('yum-plugin-security')
    end
  end

  context 'rhsm_errata_level' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'rhsm_errata_level'
      ).converge(described_recipe)
    end

    it 'runs the correct yum update command' do
      expect(chef_run).to run_execute('yum update --sec-severity=Low -y')
    end
  end
end

describe 'rhsm_test::unit_unregister' do
  context 'rhsm_register' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'rhsm_register'
      ).converge(described_recipe)
    end

    let(:unregister_command) { chef_run.execute('Unregister from RHSM') }

    context 'when the host is registered' do
      before(:each) do
        allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(true)
      end

      it 'runs the unregister command' do
        expect(chef_run).to run_execute('subscription-manager unregister')
      end

      it 'runs the clean command' do
        expect(unregister_command).to notify('execute[Clean RHSM Config]')
      end
    end

    context 'when the host is not registered' do
      before(:each) do
        allow_any_instance_of(Chef::Resource).to receive(:registered_with_rhsm?).and_return(false)
      end

      it 'does not run the unregister command' do
        expect(chef_run).not_to run_execute('subscription-manager unregister')
      end
    end
  end
end
