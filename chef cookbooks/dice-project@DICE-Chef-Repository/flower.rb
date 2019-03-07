#
# Cookbook Name:: dice_deployment_service
# Recipe:: flower
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

dice_user = node['dice_deployment_service']['app_user']
app_venv = node['dice_deployment_service']['app_venv']

service 'flower' do
  action :nothing
end

directory '/var/log/celery' do
  owner dice_user
  group dice_user
  mode 0755
  only_if { node['cloudify']['properties']['debug_mode'] }
end

template '/etc/init/flower.conf' do
  source 'flower.conf.erb'
  variables(user: dice_user, venv: app_venv)
  notifies :restart, 'service[celery]'
  only_if { node['cloudify']['properties']['debug_mode'] }
end
