#
# Cookbook Name:: hadoop
# Recipe:: resourcemanager_configure
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
hdfs_user = node['hadoop']['hdfs_user']
yarn_user = node['hadoop']['yarn_user']

execute 'create tmp folder' do
  command 'hadoop fs -mkdir /tmp && hadoop fs -chmod 0777 /tmp'
  group hadoop_group
  user hdfs_user
end

execute 'format state store' do
  command 'yarn resourcemanager -format-state-store'
  group hadoop_group
  user yarn_user
end
