#
# Cookbook Name:: dice_continuous_integration
# Recipe:: dice-qt
#
# Copyright 2017, XLAB
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

jenkins_home = '/var/lib/jenkins'
plugin_path = "#{jenkins_home}/plugins"

# in case we are too quick for this folder to appear
directory plugin_path do
	owner 'jenkins'
	group 'jenkins'
	mode '0755'
	action :create
end

plugin_hpi = "#{plugin_path}/dice-qt.hpi"
remote_file plugin_hpi do
	source node['dice_ci']['plugin_hpi']
	checksum node['dice_ci']['plugin_checksum']
	action :create
end

service 'jenkins' do
	action :restart
end