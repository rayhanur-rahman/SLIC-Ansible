#
# Cookbook Name:: bcpc
# Recipe:: apache-mirror
#
# Copyright 2013, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package 'apache2'

# This config is only applied to bootstrap node, for providing packages in ~/chef-bcpc/bins/
# It is not for cluster nodes.
template '/etc/apache2/sites-available/default.conf' do
  source 'apache-mirror.erb'
  variables(
    'user' => node['bcpc']['bootstrap']['admin']['user']
  )
  owner 'root'
  group 'root'
  mode 0o0644
  notifies :restart, 'service[apache2]', :delayed
end

service 'apache2' do
  action [:enable, :start]
end

link '/etc/apache2/sites-enabled/000-default.conf' do
  to '/etc/apache2/sites-available/default.conf'
end
