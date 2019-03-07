# Configure the node attributes
include_recipe "chef-marketplace::config"

user "opscode" do
  system true
  shell "/bin/sh"
  home "/opt/opscode/embedded"
  action :create
end

group "opscode" do
  members %w{opscode}
  action :create
end

# Setup the MOTD first so that the user doesn't see old data if the shell in
# before the chef-client has finished converging
motd "50-chef-marketplace-appliance" do
  source "motd.erb"
  cookbook "chef-marketplace"
  variables motd_variables
  action motd_action
end

# Register as a Chef Server plugin
include_recipe "chef-marketplace::_register_plugin"

# 'server', 'analytics', 'aio', 'compliance'
role = node["chef-marketplace"]["role"]

# Base recipes for role
include_recipe "chef-marketplace::_#{role}_enable"

# Configure runit
include_recipe "chef-marketplace::_runit"

# Enable/Disable chef-marketplace services
%w{
  reckoner
  biscotti
}.each do |service|
  if node["chef-marketplace"][service]["enabled"]
    include_recipe "chef-marketplace::_#{service}_enable"
  else
    include_recipe "chef-marketplace::_#{service}_disable"
  end
end

# Setup omnibus-ctl commands
include_recipe "chef-marketplace::_omnibus_commands"
