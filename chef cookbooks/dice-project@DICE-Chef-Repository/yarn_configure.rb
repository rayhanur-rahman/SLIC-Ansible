#
# Cookbook Name:: hadoop
# Recipe:: yarn_configure
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
yarn_user = node['hadoop']['yarn_user']

# Prepare common yarn configuration
config = {}
%w(core-site yarn-site mapred-site capacity-scheduler).each do |name|
  config[name] = node['hadoop'].fetch(name, {}).to_hash
end
# Namenode location needs to be added from runtime props.
config['core-site']['fs.defaultFS'] =
  "hdfs://#{node['cloudify']['runtime_properties']['namenode_addr']}"

ruby_block 'Lazy load FQDNs' do
  # OHAI is real pain to work with when it comes to dynamic values. We must
  # query it ruby_block in order to delay execution from compile phase to
  # converge phase or we will get bad value.
  block do
    rt_props = node['cloudify']['runtime_properties']
    config['yarn-site']['yarn.resourcemanager.hostname'] =
      rt_props.fetch('resourcemanager_addr', node['fqdn'])

    # Notes on node manager address and port
    # ======================================
    #
    # By default, node manager address is set to 0.0.0.0:0. Official
    # documentation states nothing about what exactly this means. On UNIX
    # derived systems, requesting something on port 0 usually means "assign
    # some random, unused port" and tracking address mangling through Hadoop
    # code revealed that YARN indeed follows this tradition.
    #
    # In order to keep things predictable (which is prerequisite for using
    # firewall), we fixed port number to which node manager binds.
    #
    # Keep this in sync with TOSCA library!
    config['yarn-site']['yarn.nodemanager.address'] = "#{node['fqdn']}:8039"
  end
end

# Store memory and CPU data for YARN
config['yarn-site']['yarn.nodemanager.resource.memory-mb'] =
  node['memory']['total'][/\d*/].to_i / 1024
config['yarn-site']['yarn.nodemanager.resource.cpu-vcores'] =
  node['cpu']['total'].to_i

[
  node['hadoop']['yarn-env']['YARN_LOG_DIR'],
  node['hadoop']['yarn-env']['YARN_PID_DIR']
].each do |folder|
  directory folder do
    mode '0700'
    owner yarn_user
    group hadoop_group
    action :create
    recursive true
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

template "#{conf_dir}/yarn-env.sh" do
  source 'env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables opts: node['hadoop']['yarn-env'].to_hash
  only_if { node['hadoop'].key?('yarn-env') }
end

# For some mysterious reason, YARN reads this file too, so we supply it
template "#{conf_dir}/hadoop-env.sh" do
  source 'env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables opts: node['hadoop']['hadoop-env'].to_hash
  only_if { node['hadoop'].key?('hadoop-env') }
end
