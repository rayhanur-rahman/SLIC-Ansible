include_recipe "chef-marketplace::config"

unless mirrors_reachable?
  Chef::Log.warn "Skipping package upgrade because mirrors are not available or outbound traffic is disabled..."
  return
end

bash "yum-clean-all" do
  code "yum clean all"
  only_if { node["platform_family"] == "rhel" }
end

bash "apt-get-clean" do
  code "apt-get clean"
  only_if { node["platform"] == "ubuntu" }
end

node["chef-marketplace"]["upgrade_packages"].sort.each do |pkg|
  include_recipe "chef-marketplace::_upgrade_#{pkg.tr('-', '_')}"
end
