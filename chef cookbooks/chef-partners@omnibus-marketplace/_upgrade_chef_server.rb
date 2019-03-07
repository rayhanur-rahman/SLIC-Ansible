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
