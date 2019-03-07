#
# Cookbook Name:: bcpc
# Recipe:: calico-head
#
# Copyright 2017, Bloomberg Finance L.P.
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

return unless node['bcpc']['enabled']['neutron']

include_recipe 'bcpc::packages-calico'
include_recipe 'bcpc::neutron-head'

%w(dnsmasq-base dnsmasq-utils calico-control).each do |pkg|
  package pkg do
    action :install
    notifies :restart, 'service[neutron-server]', :delayed
  end
end

cookbook_file '/usr/local/bin/calicoctl' do
  source   'calicoctl-v1.1.1'
  cookbook 'bcpc-binary-files'
  mode     '00755'
  owner    'root'
  group    'root'
end
