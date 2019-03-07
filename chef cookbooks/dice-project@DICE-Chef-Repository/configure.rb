# Cookbook Name:: cassandra
# Recipe:: configure
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

# Obtain host ip
ip = if node['cloudify']['runtime_properties'].key?('host_ip')
       node['cloudify']['runtime_properties']['host_ip']
     else
       node['ipaddress']
     end

# If no seeds are present, we are the seed
seeds = if node['cloudify']['runtime_properties'].key?('seeds')
          node['cloudify']['runtime_properties']['seeds'].join(',')
        else
          ip
        end

# Configure cassandra
cassandra_conf = node['cassandra']['yaml'].to_hash
cassandra_conf.merge!(node['cloudify']['properties']['configuration'].to_hash)

# Next three settings cannot be overriden by user
cassandra_conf['listen_address'] = ip
cassandra_conf['rpc_address'] = '0.0.0.0'
cassandra_conf['broadcast_rpc_address'] = ip
cassandra_conf['seed_provider'] = [{
  'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
  'parameters' => [{
    'seeds' => seeds
  }]
}]

file '/etc/cassandra/cassandra.yaml' do
  mode 0644
  action :create
  content cassandra_conf.to_yaml
end

template '/etc/cassandra/logback.xml' do
  source 'logback.xml.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables log_dir: '/var/log/cassandra'
end

remote_file 'Copy Cassandra env file' do
  path '/etc/cassandra/cassandra-env.sh'
  source 'file:///usr/share/cassandra/conf/cassandra-env.sh'
  owner 'root'
  group 'root'
  mode 0755
end

remote_file 'Copy Cassandra snitch config' do
  path '/etc/cassandra/cassandra-rackdc.properties'
  source 'file:///usr/share/cassandra/conf/cassandra-rackdc.properties'
  owner 'root'
  group 'root'
  mode 0755
end
