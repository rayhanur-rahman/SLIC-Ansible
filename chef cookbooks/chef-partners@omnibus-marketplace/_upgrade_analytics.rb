bash "opscode-analytics-ctl reconfigure" do
  code "opscode-analytics-ctl reconfigure"
  only_if { analytics_configured? }
  action :nothing
end

bash "opscode-analytics-ctl stop" do
  code "opscode-analytics-ctl stop"
  only_if { analytics_configured? }
end

chef_ingredient "analytics" do
  action :upgrade
  notifies :run, "bash[opscode-analytics-ctl reconfigure]", :immediately
  notifies :run, "bash[yum-clean-all]", :immediately
  notifies :run, "bash[apt-get-clean]", :immediately
end

bash "opscode-analytics-ctl stop" do
  code "opscode-analytics-ctl stop"
  only_if { analytics_configured? }
end
