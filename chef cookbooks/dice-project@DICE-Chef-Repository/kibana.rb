# Cookbook Name:: dmon
# Recipe:: kibana
#
# Copyright 2016, XLAB d.o.o.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

install_dir = node['dmon']['kb']['install_dir']
dmon_user = node['dmon']['user']
dmon_group = node['dmon']['group']

kb_tar = "#{Chef::Config[:file_cache_path]}/kb.tar.gz"
remote_file kb_tar do
  source node['dmon']['kb']['source']
  checksum node['dmon']['kb']['checksum']
end

poise_archive kb_tar do
  destination install_dir
end

bash 'Install kibana plugins' do
  code <<-EOH
    cd #{install_dir}/bin
    ./kibana plugin --install elasticsearch/marvel/2.2.0
    ./kibana plugin --install elastic/sense
    EOH
end

template "#{install_dir}/config/kibana.yml" do
  source 'kibana.yml.erb'
  owner dmon_user
  group dmon_group
  action :create
  variables(
    kbPort: node['dmon']['kb']['port'],
    esIp: node['dmon']['es']['ip'],
    esPort: node['dmon']['es']['port'],
    kibanaPID: "#{node['dmon']['install_dir']}/src/pid/kibana.pid",
    kibanaLog: "#{node['dmon']['install_dir']}/src/logs/kibana.log"
  )
end

execute 'Setting Kibana permissions' do
  command "chown -R #{dmon_user}:#{dmon_group} #{install_dir}"
end

template '/etc/init/kibana.conf' do
  source 'kibana.conf.erb'
  variables(
    install_dir: install_dir,
    user: dmon_user,
    group: dmon_group
  )
end

cookbook_file '/opt/kibana/optimize/bundles/src/ui/public/images/kibana.svg' do
  source 'kibana.svg'
end

service 'kibana' do
  action [:enable, :start]
end
