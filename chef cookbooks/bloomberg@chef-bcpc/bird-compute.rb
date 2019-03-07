#
# Cookbook Name:: bcpc
# Recipe:: bird-compute
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

include_recipe 'bcpc::packages-bird'

package "bird" do
  action :install
end

service "bird" do
  action [:enable, :start]
end

# disable IPv6 for now
service 'bird6' do
  action [:disable, :stop]
end

template "/etc/bird/bird.conf" do
  source "bird.conf.erb"
  mode 00644
  variables(
    lazy {
      {
        :as_number => node['bcpc']['calico']['bgp']['as_number'],
        :workload_interface => node['bcpc']['calico']['bgp']['workload_interface'],
        :upstream_peer => node['bcpc']['calico']['bgp']['upstream_peer']
      }
    }
  )
  notifies :restart, "service[bird]", :immediately
end
