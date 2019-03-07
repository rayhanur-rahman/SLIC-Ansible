#
# Cookbook Name:: dice_common
# Recipe:: consul_common
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

group 'consul' do
  action :create
end

user 'consul' do
  gid 'consul'
  shell '/bin/bash'
  action :create
end

directory '/var/lib/consul' do
  mode 0755
  owner 'consul'
  group 'consul'
  action :create
  recursive true
end

package 'unzip'

temp_file = "#{Chef::Config[:file_cache_path]}/consul.zip"

remote_file temp_file do
  source node['dice_common']['consul-zip']
  checksum node['dice_common']['consul-sha256sum']
end

execute 'Unzip consul' do
  command "unzip -o #{temp_file}"
  cwd '/usr/bin'
end
