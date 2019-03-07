# Possibly run actions
bash "chef-server-ctl reconfigure" do
  code "chef-server-ctl reconfigure"
  only_if { chef_server_configured? }
  action :nothing
end

bash "chef-server-ctl upgrade" do
  code "chef-server-ctl upgrade"
  only_if { chef_server_configured? }
  action :nothing
end

bash "chef-server-ctl start" do
  code "chef-server-ctl start"
  only_if { chef_server_configured? }
  action :nothing
end

bash "opscode-reporting-ctl reconfigure" do
  code "opscode-reporting-ctl reconfigure"
  only_if { chef_server_configured? }
  action :nothing
end

bash "chef-manage-ctl reconfigure" do
  code "chef-manage-ctl reconfigure"
  only_if { chef_server_configured? }
  action :nothing
end

# Chef Server
bash "chef-server-ctl stop" do
  code "chef-server-ctl stop"
  only_if { chef_server_configured? }
end

chef_ingredient "chef-server" do
  action :upgrade

  notifies :run, "bash[chef-server-ctl reconfigure]", :immediately
  notifies :run, "bash[chef-server-ctl upgrade]", :immediately
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "chef-server-ctl restart" do
  code "chef-server-ctl restart"
  only_if { chef_server_configured? }
end

# Chef Reporting
chef_ingredient "reporting" do
  action :upgrade

  notifies :run, "bash[chef-server-ctl start]", :immediately
  notifies :run, "bash[opscode-reporting-ctl reconfigure]", :immediately
  notifies :run, "bash[chef-server-ctl restart]"
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

# Chef Manage
bash "chef-manage-ctl stop" do
  code "chef-manage-ctl stop"
  retries 3 # sometimes the worker takes a couple tries to die
  only_if { chef_server_configured? }
end

chef_ingredient "manage" do
  action :upgrade

  notifies :run, "bash[chef-server-ctl start]", :immediately
  notifies :run, "bash[chef-manage-ctl reconfigure]", :immediately
  notifies :run, "bash[chef-server-ctl restart]"
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "chef-manage-ctl restart" do
  code "chef-manage-ctl restart"
  only_if { chef_server_configured? }
end
