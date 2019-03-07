#
# Cookbook Name:: hadoop
# Recipe:: nodemanager_configure
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

hadoop_group = node['hadoop']['group']
yarn_user = node['hadoop']['yarn_user']

data_dirs = node['hadoop']['yarn-site']['yarn.nodemanager.local-dirs']
dirs = data_dirs.split(',').map { |v| v.gsub('file://', '') }
log_dirs = node['hadoop']['yarn-site']['yarn.nodemanager.log-dirs']
dirs += log_dirs.split(',').map { |v| v.gsub('file://', '') }

dirs.each do |folder|
  directory folder do
    mode '0770'
    owner yarn_user
    group hadoop_group
    action :create
    recursive true
  end
end
