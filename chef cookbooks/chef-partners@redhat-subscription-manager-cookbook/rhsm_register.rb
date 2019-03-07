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

module RhsmCookbook
  class RhsmRegister < Chef::Resource
    resource_name :rhsm_register

    property :_name_unused,          String, name_property: true
    property :activation_key,        [String, Array], coerce: proc { |x| Array(x) }
    property :satellite_host,        String
    property :organization,          String
    property :environment,           String
    property :username,              String
    property :password,              String
    property :auto_attach,           [TrueClass, FalseClass], default: false
    property :install_katello_agent, [TrueClass, FalseClass], default: true
    property :force,                 [TrueClass, FalseClass], default: false

    action :register do
      package 'subscription-manager'

      unless new_resource.satellite_host.nil? || registered_with_rhsm?
        remote_file "#{Chef::Config[:file_cache_path]}/katello-package.rpm" do
          source "http://#{new_resource.satellite_host}/pub/katello-ca-consumer-latest.noarch.rpm"
          action :create
          notifies :install, 'yum_package[katello-ca-consumer-latest]', :immediately
          not_if { katello_cert_rpm_installed? }
        end

        yum_package 'katello-ca-consumer-latest' do
          options '--nogpgcheck'
          source "#{Chef::Config[:file_cache_path]}/katello-package.rpm"
          action :nothing
        end

        file "#{Chef::Config[:file_cache_path]}/katello-package.rpm" do
          action :delete
        end
      end

      execute 'Register to RHSM' do
        sensitive new_resource.sensitive
        command register_command
        action :run
        not_if { registered_with_rhsm? }
      end

      yum_package 'katello-agent' do
        action :install
        only_if { new_resource.install_katello_agent && !new_resource.satellite_host.nil? }
      end
    end

    action :unregister do
      execute 'Unregister from RHSM' do
        command 'subscription-manager unregister'
        action :run
        only_if { registered_with_rhsm? }
        notifies :run, 'execute[Clean RHSM Config]', :immediately
      end

      execute 'Clean RHSM Config' do
        command 'subscription-manager clean'
        action :nothing
      end
    end

    action_class do
      include RhsmCookbook::RhsmHelpers
    end
  end
end
