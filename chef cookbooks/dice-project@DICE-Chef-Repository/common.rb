#
# Cookbook Name:: dice_deployment_service
# Recipe:: common
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
app_prefix = node['dice_deployment_service']['app_prefix']

group dice_user do
  action :create
end

user dice_user do
  gid dice_user
  shell '/bin/bash'
  action :create
end

directory "/home/#{dice_user}" do
  mode 0700
  user dice_user
  group dice_user
  action :create
end

directory app_prefix do
  mode 0755
  user dice_user
  group dice_user
  action :create
end
