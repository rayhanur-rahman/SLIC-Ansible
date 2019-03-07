#
# Cookbook Name:: hadoop
# Recipe:: hdfs_configure
#
# Copyright 2016, XLAB
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

conf_dir = node['hadoop']['conf_dir']
hadoop_group = node['hadoop']['group']
hdfs_user = node['hadoop']['hdfs_user']

# Prepare common hdfs configuration (for data nodes and name node)
config = {}
%w(core-site hdfs-site).each do |name|
  config[name] = node['hadoop'].fetch(name, {}).to_hash
end

ruby_block 'Lazy load FQDN' do
  # OHAI is real pain to work with when it comes to dynamic values. We must
  # query it ruby_block in order to delay execution from compile phase to
  # converge phase or we will get bad value.
  block do
    rt_props = node['cloudify']['runtime_properties']
    namenode = rt_props.fetch('namenode_addr', node['fqdn'])
    config['core-site']['fs.defaultFS'] = "hdfs://#{namenode}"
  end
end

config.each do |name, data|
  template "#{conf_dir}/#{name}.xml" do
    source 'site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables opts: data
  end
end

[
  node['hadoop']['hadoop-env']['HADOOP_LOG_DIR'],
  node['hadoop']['hadoop-env']['HADOOP_PID_DIR']
].each do |folder|
  directory folder do
    mode '0700'
    owner hdfs_user
    group hadoop_group
    action :create
    recursive true
  end
end

template "#{conf_dir}/hadoop-env.sh" do
  source 'env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables opts: node['hadoop']['hadoop-env'].to_hash
  only_if { node['hadoop'].key?('hadoop-env') }
end
