#
# Cookbook Name:: hadoop
# Recipe:: namenode_configure
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

# Run commmon stuff
hadoop_group = node['hadoop']['group']
hdfs_user = node['hadoop']['hdfs_user']

name_dirs = node['hadoop']['hdfs-site']['dfs.namenode.name.dir'].split(',')
name_dirs_local = name_dirs.map { |v| v.gsub('file://', '') }

name_dirs_local.each do |folder|
  directory folder do
    mode '0770'
    owner hdfs_user
    group hadoop_group
    action :create
    recursive true
  end
end

execute 'hdfs namenode format' do
  command 'hdfs namenode -format'
  creates "#{name_dirs_local[0]}/current/VERSION"
  group hadoop_group
  user hdfs_user
end
