# Setup cloud-init to initialize metered images on AWS.
# BYOL images on Azure and AWS setup the instance via the resource manager
# that is launching the VM or instance, e.g: the Azure Resource Manager
# template or the AWS CloudFormation template. Therefore, we don't need to
# worry about cloud-init on those machines.

return unless node["chef-marketplace"]["platform"] == "aws" &&
    node["chef-marketplace"]["license"]["type"] == "flexible"

package "cloud-init" do
  action :install
  only_if { mirrors_reachable? }
end

directory "/var/lib/cloud/scripts/per-instance" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

# Run the setup script as part of cloud-init at initial boot time
template "/var/lib/cloud/scripts/per-instance/chef-marketplace-setup" do
  source "chef-marketplace-cloud-init-setup.erb"
  owner "root"
  group "root"
  mode "0755"
end

directory "/etc/cloud" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

template "/etc/cloud/cloud.cfg" do
  source "cloud.cfg.erb"
  cookbook "chef-marketplace"
  variables(
    default_user: cloud_cfg_default_user,
    gecos: cloud_cfg_gecos,
    ssh_pwauth: cloud_cfg_ssh_pwauth,
    locale_configfile: cloud_cfg_locale_configfile,
    distro: cloud_cfg_distro
  )
  action :create
end
