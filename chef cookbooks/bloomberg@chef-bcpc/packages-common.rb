#
# Cookbook Name:: bcpc
# Recipe:: packages-common
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

# This recipe installs OS packages which are required by all node types.

bash 'remove-foreign-arch' do
  user 'root'
  code 'dpkg --remove-architecture i386'
  only_if 'dpkg --print-foreign-architectures | grep i386'
end

# run apt-get update at the start of every Chef run if so configured
if node['bcpc']['enabled']['always_update_package_lists'] then
  bash "run-apt-get-update" do
    user "root"
    code "DEBIAN_FRONTEND=noninteractive apt-get update"
  end
end

# configure dpkg to not complain about our managed config files
# (configured in two places to make really sure it happens)
cookbook_file '/etc/apt/apt.conf.d/01managed_config_files' do
  source 'packages-common.etc_apt_apt.conf.d_01managed_config_files'
  owner  'root'
  group  'root'
  mode   00644
end

cookbook_file '/etc/dpkg/dpkg.cfg.d/managed_config_files' do
  source 'packages-common.etc_dpkg_dpkg.cfg.d_managed_config_files'
  owner  'root'
  group  'root'
  mode   00644
end

package 'jq'
package 'patch'
package 'sshpass'  # GitHub #112 -- required for nodessh.sh
# logtail is used for some zabbix checks
package 'logtail'
package 'crudini'

# Remove spurious logging failures from this package
package "powernap" do
  action :remove
end

if node['bcpc']['enabled']['apt_dist_upgrade']
  include_recipe "apt::default"
  bash "perform-dist-upgrade" do
    user "root"
    code "DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade"
  end
end

if node['bcpc']['enabled']['apt_upgrade']
  include_recipe "apt::default"
  bash "perform-upgrade" do
    user "root"
    code "DEBIAN_FRONTEND=noninteractive apt-get -y upgrade"
  end
end
