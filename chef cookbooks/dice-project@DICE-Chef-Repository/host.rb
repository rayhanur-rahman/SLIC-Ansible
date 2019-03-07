#
# Cookbook Name:: dice_common
# Recipe:: default
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

# Only setup hostname once
marker = 'DICE-HOSTNAME-SET'
return unless File.open('/etc/hosts', 'r').read.index(/#{marker}/).nil?

# hostname format:
#  * deployment marker (6 characters)
#  * node id (max 40 characters)
#  * MAC address (12 characters)
deploy_abbrev = node['cloudify']['deployment_id'][0, 6].tr('_', '-')
node_name = node['cloudify']['node_id'].sub(/_[^_]*$/, '')
node_name_dash = node_name.tr('_', '-')[0, 40]
mac_concat = node['macaddress'].delete ':'

hostname = "#{deploy_abbrev}-#{node_name_dash}-#{mac_concat}".downcase
fqdn = "#{hostname}.node.consul"

node.default['cloudify']['runtime_properties']['ip'] = node['ipaddress']
node.default['cloudify']['runtime_properties']['fqdn'] = fqdn

set_hostname hostname do
  fqdn fqdn
  marker marker
end
