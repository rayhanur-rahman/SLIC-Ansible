case node["platform"]
when "oracle"
  include_recipe "chef-marketplace::_oracle_common_enable"
end

directory "/etc/chef/ohai/hints" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

file "/etc/chef/ohai/hints/#{node['chef-marketplace']['platform']}.json" do
  owner "root"
  group "root"
  mode "0755"
  action :create_if_missing
end

user node["chef-marketplace"]["user"] do
  home "/home/#{node['chef-marketplace']['user']}"
  shell "/bin/bash"
  action [:create, :lock]
end

package cron_package do
  action :install
  only_if do
    (node["chef-marketplace"]["reporting"]["cron"]["enabled"] ||
     node["chef-marketplace"]["analytics"]["trimmer"]["enabled"]
    ) && mirrors_reachable?
  end
end

package "walinuxagent" do
  action [:install, :upgrade]
  only_if { node["chef-marketplace"]["platform"] == "azure" && mirrors_reachable? }
end

service "firewalld" do
  action [:disable, :stop]
  only_if { node["platform"] == "centos" && node["platform_version"].start_with?("7.") }
end

chef_marketplace_cfn_tools "centos7" do
  action :install
  only_if { node["chef-marketplace"]["platform"] == "aws" }
end
