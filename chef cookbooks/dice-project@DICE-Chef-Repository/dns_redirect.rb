#
# Cookbook Name:: dice_common
# Recipe:: dns_redirect
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

execute 'chattr -i /etc/resolv.conf' do
  not_if { File.symlink?('/etc/resolv.conf') }
end

file '/etc/resolv.conf' do
  manage_symlink_source false
  action :delete
end

template '/etc/resolv.conf' do
  source 'resolv.conf.erb'
  variables master: node['cloudify']['properties']['dns_server']
end

execute 'chattr +i /etc/resolv.conf'
