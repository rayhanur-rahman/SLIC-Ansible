#
# Cookbook Name:: hadoop
# Recipe:: datanode_configure
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

data_dirs = node['hadoop']['hdfs-site']['dfs.datanode.data.dir'].split(',')
data_dirs_local = data_dirs.map { |v| v.gsub('file://', '') }

data_dirs_local.each do |folder|
  directory folder do
    mode '0700'
    owner node['hadoop']['hdfs_user']
    group node['hadoop']['group']
    action :create
    recursive true
  end
end
