#
# Cookbook Name:: dmon_agent
# Recipe:: mongo
#
# Copyright 2017, XLAB
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
#

# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

dmon_master = node['cloudify']['properties']['monitoring']['dmon_address']
install_dir = node['dmon_agent']['install_dir']

set_role 'mongodb' do
  dmon dmon_master
  hostname node['hostname']
end

dmon_user = node['dmon_agent']['mongodb']['dmon_user']
dmon_pass = SecureRandom.base64 30
dmon_script = "#{Chef::Config[:file_cache_path]}/add_dmon.js"
auth_db = 'admin'

template dmon_script do
  source 'add_mongo_user.js.erb'
  variables(
    admin_user: node['cloudify']['runtime_properties']['admin_user'],
    admin_pass: node['cloudify']['runtime_properties']['admin_pass'],
    pass: dmon_pass, user: dmon_user, auth_db: auth_db, role: 'clusterMonitor'
  )
end

bash 'Create DMON mongo user' do
  code "mongo --host 127.0.0.1:27017 #{dmon_script}"
  retries 10
end

node.default['cloudify']['runtime_properties']['dmon_user'] = dmon_user
node.default['cloudify']['runtime_properties']['dmon_pass'] = dmon_pass

file dmon_script do
  action :delete
end

template '/etc/collectd/collectd.conf.d/mongo.conf' do
  source 'collectd-mongo.conf.erb'
  variables(
    install_dir: install_dir, user: dmon_user, pass: dmon_pass,
    auth_db: auth_db
  )
end

service 'collectd' do
  action :restart
end
