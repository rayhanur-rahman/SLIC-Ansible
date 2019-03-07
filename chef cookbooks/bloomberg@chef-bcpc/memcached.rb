#
# Cookbook Name:: bcpc
# Recipe:: memcached
#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'memcached' do
  action :install
end

file '/var/log/memcached.log' do
  owner 'memcache'
  group 'memcache'
  mode  00644
end

template '/etc/memcached.conf' do
  source   'memcached.conf.erb'
  owner    'root'
  group    'root'
  mode     00644
  variables(
    connections: node['bcpc']['memcached']['connections'],
    verbose:     node['bcpc']['memcached']['debug']
  )
  notifies :restart, 'service[memcached]', :immediate
end

logrotate_app 'memcached' do
  path      '/var/log/memcached.log'
  frequency 'daily'
  rotate    10
  options   ['compress', 'delaycompress', 'notifempty', 'copytruncate']
end

service 'memcached' do
  action [:enable, :start]
end
