# Hook into the Chef Server as a plugin

return unless node["chef-marketplace"]["role"] =~ /server|aio/

marketplace_dir = "/var/opt/opscode/chef-marketplace"
plugin_dir = "/var/opt/opscode/plugins"

directory marketplace_dir do
  recursive true
  action :create
end

directory plugin_dir do
  recursive true
  action :create
end

cookbook_file "#{plugin_dir}/chef-marketplace.rb" do
  manage_symlink_source true
  source "chef-marketplace-plugin.rb"
  action :create
end

template "#{marketplace_dir}/config.rb" do
  manage_symlink_source true
  source "chef-marketplace-plugin-config.rb.erb"
  action :create
end
