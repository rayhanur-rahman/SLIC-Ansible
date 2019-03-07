directory "/opt/opscode/embedded/service/omnibus-ctl" do
  action :delete
end

file "/opt/opscode/embedded/service/omnibus-ctl/marketplace_setup.rb" do
  action :delete
end

template "/etc/cron.d/reporting-partition-cleanup" do
  action :delete
end
