#
# Cookbook Name:: bcpc
# Recipe:: etcd-head
#
# Copyright 2017, Bloomberg Finance L.P.
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

return unless node['bcpc']['enabled']['neutron']

include_recipe 'bcpc::etcd-common'

ruby_block 'join-existing-etcd-cluster' do
  block do
    headnodes = get_head_nodes
    headnodes.delete(node)
    random_etcd_member = get_shuffled_servers(headnodes)[0]
    Mixlib::ShellOut.new("curl -X POST http://#{random_etcd_member['bcpc']['management']['ip']}:2379/v2/members -H \"Content-Type: application/json\" -d '{ \"peerURLs\" : [\"http://#{node['bcpc']['management']['ip']}:2380\"] }'").run_command.error!
  end
  only_if { get_head_nodes.length > 1 }
end
