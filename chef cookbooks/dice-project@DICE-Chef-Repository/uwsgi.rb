#
# Cookbook Name:: dice_deployment_service
# Recipe:: uwsgi
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
app_folder = node['dice_deployment_service']['app_folder']
app_socket = node['dice_deployment_service']['app_socket']
app_venv = node['dice_deployment_service']['app_venv']

service 'uwsgi' do
  action :nothing
end

directory '/var/log/uwsgi' do
  owner dice_user
  group dice_user
  mode 0755
end

directory '/etc/uwsgi/sites' do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
end

python_package 'uwsgi' do
  user dice_user
  group dice_user
  virtualenv app_venv
end

template '/etc/uwsgi/sites/dice-deployment-service.ini' do
  source 'dice-deployment-service.ini.erb'
  variables(app_folder: app_folder, app_venv: app_venv, app_socket: app_socket)
  notifies :restart, 'service[uwsgi]'
end

template '/etc/init/uwsgi.conf' do
  source 'uwsgi.conf.erb'
  variables(user: dice_user, app_venv: app_venv)
  notifies :restart, 'service[uwsgi]'
end
