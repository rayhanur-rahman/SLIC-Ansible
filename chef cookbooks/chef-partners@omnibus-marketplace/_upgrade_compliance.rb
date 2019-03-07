bash "chef-compliance-ctl reconfigure" do
  code "chef-compliance-ctl reconfigure"
  only_if { compliance_configured? }
  action :nothing
end

ruby_block "remove-compliance-from-cache" do
  block do
    package = Dir["#{Chef::Config[:file_cache_path]}/*"].find { |f| f =~ /chef-compliance/ }
    FileUtils.rm(package) if package && File.exist?(package)
  end

  action :nothing
end

bash "chef-compliance-ctl stop" do
  code "chef-compliance-ctl stop"
  only_if { compliance_configured? }
end

chef_ingredient "compliance" do
  action :upgrade
  notifies :run, "bash[chef-compliance-ctl reconfigure]", :immediately
  notifies :run, "ruby_block[remove-compliance-from-cache]", :immediately
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "chef-compliance-ctl start" do
  code "chef-compliance-ctl start"
  only_if { compliance_configured? }
end
