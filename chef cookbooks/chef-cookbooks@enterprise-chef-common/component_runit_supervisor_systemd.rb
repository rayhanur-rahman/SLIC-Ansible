#
# Cookbook Name:: enterprise
# Resource:: component_runit_supervisor
#
# Copyright:: 2018, Chef Software, Inc.
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
include ComponentRunitSupervisorResourceMixin

provides :component_runit_supervisor do |node|
  node['init_package'] == 'systemd'
end

action :create do
  template "/etc/systemd/system/#{unit_name}" do
    cookbook 'enterprise'
    owner 'root'
    group 'root'
    mode '0644'
    variables(install_path: new_resource.install_path,
              project_name: new_resource.name)
    source 'runsvdir-start.service.erb'
    notifies :run, 'execute[systemctl daemon-reload]', :immediately
  end

  execute 'systemctl daemon-reload' do
    action :nothing
  end

  # This cookbook originally installed its unit files in /usr/lib/systemd/system.
  file "/usr/lib/systemd/system/#{unit_name}" do
    action :delete
    notifies :run, 'execute[systemctl daemon-reload]', :immediately
  end

  service unit_name do
    action [:enable, :start]
    provider Chef::Provider::Service::Systemd
  end
end

action :delete do
  Dir["#{new_resource.install_path}/service/*"].each do |svc|
    execute "#{new_resource.install_path}/embedded/bin/sv stop #{svc}" do
      retries 5
      only_if { ::File.exist? "#{new_resource.install_path}/embedded/bin/sv" }
    end
  end

  execute 'systemctl daemon-reload' do
    action :nothing
  end

  service unit_name do
    action [:stop, :disable]
    provider Chef::Provider::Service::Systemd
  end

  file "/etc/systemd/system/#{unit_name}" do
    action :delete
    notifies :run, 'execute[systemctl daemon-reload]', :immediately
  end
end

action_class do
  def unit_name
    "#{new_resource.name}-runsvdir-start.service"
  end
end
