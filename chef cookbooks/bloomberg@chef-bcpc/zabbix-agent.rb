#
# Cookbook Name:: bcpc
# Recipe:: zabbix-agent
#
# Copyright 2015, Bloomberg Finance L.P.
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

if node['bcpc']['enabled']['monitoring'] then
    include_recipe "bcpc::default"
    include_recipe "bcpc::packages-zabbix"

    %w{zabbix-agent zabbix-get zabbix-sender}.each do |zabbix_package|
      package zabbix_package do
        action :install
      end
    end

    group "adm" do
        action :modify
        append true
        members "zabbix"
    end

    template "/etc/zabbix/zabbix_agent.conf" do
        source "zabbix_agent.conf.erb"
        owner node['bcpc']['zabbix']['user']
        group "root"
        mode 00600
        notifies :restart, "service[zabbix-agent]", :delayed
    end

    template "/etc/zabbix/zabbix_agentd.conf" do
        source "zabbix_agentd.conf.erb"
        owner node['bcpc']['zabbix']['user']
        group "root"
        mode 00600
        notifies :restart, "service[zabbix-agent]", :delayed
    end

    template "/etc/zabbix/zabbix_agentd.d/zabbix-openstack.conf" do
        source "zabbix_openstack.conf.erb"
        owner node['bcpc']['zabbix']['user']
        group "root"
        mode 00600
        only_if do get_cached_head_node_names.include?(node['hostname']) end
        notifies :restart, "service[zabbix-agent]", :immediately
    end

    template "/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf" do
        source "zabbix_agentd_userparameters_mysql.conf.erb"
        owner node['bcpc']['zabbix']['user']
        group "root"
        mode 00600
        only_if 'test -f /etc/mysql/debian.cnf'
        notifies :restart, "service[zabbix-agent]", :immediately
    end

    template '/etc/zabbix/zabbix_agentd.d/userparameter_ceph.conf' do
        source 'zabbix_agentd_userparameters_ceph.conf.erb'
        owner node['bcpc']['zabbix']['user']
        group 'root'
        mode 00600
        only_if do
          get_ceph_mon_nodes.include?(node)
        end
        notifies :restart, 'service[zabbix-agent]', :delayed
    end

    # Deprecated by cron-invoked check
    file '/etc/zabbix/zabbix_agentd.d/userparameter_ephemeral.conf' do
      action :delete
      notifies :restart, 'service[zabbix-agent]', :delayed
    end

    template "/etc/zabbix/zabbix_agentd.d/userparameter_bootstrap.conf" do
        source "zabbix_agentd_userparameters_bootstrap.conf.erb"
        owner node['bcpc']['zabbix']['user']
        group "root"
        mode 00600
        only_if { File.exist?('/opt/opscode/bin/chef-server-ctl') }
        notifies :restart, "service[zabbix-agent]", :immediately
    end

    service "zabbix-agent" do
        action [:enable, :start]
        provider Chef::Provider::Service::Init::Debian
        status_command "service zabbix-agent status"
    end

    cookbook_file "/tmp/python-requests-aws_0.1.6_all.deb" do
        source "python-requests-aws_0.1.6_all.deb"
        cookbook 'bcpc-binary-files'
        owner "root"
        mode 00444
    end

    package "requests-aws" do
        provider Chef::Provider::Package::Dpkg
        source "/tmp/python-requests-aws_0.1.6_all.deb"
        action :install
    end

    file "/usr/local/bin/zabbix_bucket_stats" do
        action :delete
        only_if do get_cached_head_node_names.include?(node['hostname']) end
    end

    file "/usr/local/bin/zabbix_discover_buckets" do
        action :delete
        only_if do get_cached_head_node_names.include?(node['hostname']) end
    end

    cookbook_file '/usr/local/bin/ceph_health_filter.sh' do
      source 'ceph_health_filter.sh'
      owner 'root'
      group 'root'
      mode 00755
    end
end
