#
# Cookbook Name:: mongodb
# Recipe:: configure_router
#
# Copyright 2017 XLAB d.o.o.
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

props = node['cloudify']['properties']
rt_props = node['cloudify']['runtime_properties']

# IP address that we bind to
ips = if props.fetch('bind_ip', '') == 'global'
        ['0.0.0.0']
      else
        [node['ipaddress'], '127.0.0.1']
      end
replica_name = rt_props['replica_name']
hosts = rt_props['members'].map { |x| x + ':27017' }.join ','

template '/etc/mongod.conf' do
  source 'mongod-router.conf.erb'
  variables ips: ips, replica_name: replica_name, hosts: hosts
end
