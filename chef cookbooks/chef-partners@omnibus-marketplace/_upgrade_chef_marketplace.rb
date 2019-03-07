bash "chef-marketplace-ctl reconfigure" do
  code "chef-marketplace-ctl reconfigure"
  action :nothing
end

bash "chef-marketplace-ctl stop" do
  code "chef-marketplace-ctl stop"
end

chef_ingredient "marketplace" do
  action :upgrade
  notifies :run, "bash[chef-marketplace-ctl reconfigure]"
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "chef-marketplace-ctl start" do
  code "chef-marketplace-ctl start"
end
