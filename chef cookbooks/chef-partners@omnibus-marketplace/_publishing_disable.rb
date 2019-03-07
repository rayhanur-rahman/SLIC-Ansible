motd "50-chef-marketplace-appliance" do
  action :delete
end

file "etc/chef/ohai/hints/#{node['chef-marketplace']['platform']}.json" do
  action :delete
end

user node["chef-marketplace"]["user"] do
  action :delete
end

package "cloud-init" do
  action :uninstall
  only_if { mirrors_reachable? }
end

directory "/etc/cloud" do
  action :delete
end

template "/etc/cloud/cloud.cfg" do
  action :delete
end

marketplace_dir = "/var/opt/opscode/chef-marketplace"

file "#{marketplace_dir}/config.rb" do
  action :delete
end

directory marketplace_dir do
  action :delete
end

file "/var/opt/opscode/plugins/chef-marketplace.rb" do
  action :delete
end
