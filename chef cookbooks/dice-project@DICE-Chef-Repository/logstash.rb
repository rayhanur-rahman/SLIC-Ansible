# Cookbook Name:: dmon
# Recipe:: logstash
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

install_dir = node['dmon']['ls']['install_dir']
dmon_user = node['dmon']['user']
dmon_group = node['dmon']['group']

ls_tar = "#{Chef::Config[:file_cache_path]}/ls.tar.gz"
remote_file ls_tar do
  source node['dmon']['ls']['source']
  checksum node['dmon']['ls']['checksum']
  action :create
end

poise_archive ls_tar do
  destination install_dir
end

file "#{node['dmon']['install_dir']}/src/logs/logstash.log" do
  owner dmon_user
  group dmon_group
end

execute 'Setting ls permissions' do
  command "chown -R #{dmon_user}:#{dmon_group} #{install_dir}"
end

ssl_cnf = "#{Chef::Config[:file_cache_path]}/ssl.cnf"
template ssl_cnf do
  source 'ssl.cnf.erb'
  variables ip: node['ipaddress']
end

bash 'Create Lumberjack certificate' do
  code <<-EOF
    openssl req -new -nodes -x509 -newkey rsa:2048 -sha256 -days 730 \
      -config #{ssl_cnf} \
      -out    #{node['dmon']['install_dir']}/src/keys/logstash-forwarder.crt \
      -keyout #{node['dmon']['install_dir']}/src/keys/logstash-forwarder.key
    EOF
end

ruby_block 'Store lumberjack crt' do
  block do
    node.default['cloudify']['runtime_properties']['lsf_crt'] =
      IO.read("#{node['dmon']['install_dir']}/src/keys/logstash-forwarder.crt")
  end
end

bash 'logrotate' do
  code <<-EOH
    echo "#{node['dmon']['install_dir']}/src/logs/logstash.log{
    size 20M
    create 777 ubuntu ubuntu
    rotate 4
    }" >> /etc/logrotate.conf
    cd /etc
    logrotate -s /var/log/logstatus logrotate.conf
    EOH
end

template '/etc/init/dmon-ls.conf' do
  source 'dmon-ls.conf.erb'
  variables(
    user: dmon_user,
    group: dmon_group,
    install_dir: install_dir,
    conf_file: "#{node['dmon']['install_dir']}/src/conf/logstash.conf",
    log_file: "#{node['dmon']['install_dir']}/src/logs/logstash.log",
    heap_size: node['dmon']['ls']['heap_size'],
    core_workers: node['dmon']['ls']['core_workers']
  )
end
