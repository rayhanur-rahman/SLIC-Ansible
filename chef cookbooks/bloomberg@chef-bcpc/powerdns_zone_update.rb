#
# Cookbook Name:: bcpc
# Recipe:: powerdns_zone_update
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

return unless node['bcpc']['enabled']['dns']

# Once zone serial number is stored in data bag, it never auto-increments. We
# want to increase the serial number and notify nameservers once for each
# zone per cluster rechef.
template '/usr/local/etc/dns-update-slaves' do
  source 'dns-update-slaves.erb'
  owner 'root'
  group 'root'
  mode 00640
  variables(
    :slaves => node['bcpc']['pdns']['slaves']
  )
  notifies :run, 'ruby_block[powerdns-update-all-zones]', :immediately
end

cookbook_file '/usr/local/bin/dns-update-zone.sh' do
  source 'dns-update-zone.sh'
  owner 'root'
  group 'root'
  mode 00755
end

ruby_block 'powerdns-update-all-zones' do
  block do
    system 'if_vip /usr/local/bin/dns-update-zone.sh'
  end
end
