# Add chef-server-ctl marketplace-setup shim for backwards compatability
directory "/opt/opscode/embedded/service/omnibus-ctl" do
  owner "root"
  group "root"
  recursive true
  action :create
end

file "/opt/opscode/embedded/service/omnibus-ctl/marketplace_setup.rb" do
  owner "root"
  group "root"
  content <<'EOF'
add_command_under_category 'marketplace-setup', 'marketplace', 'Set up the Chef Server Marketplace Appliance', 2 do
  run_command("chef-marketplace-ctl setup #{ARGV[1..-1].join(' ')}")
end
EOF
  action :create
end

template "/etc/cron.d/reporting-partition-cleanup" do
  source "reporting-partition-cleanup.erb"
  variables(
    expression: node["chef-marketplace"]["reporting"]["cron"]["expression"],
    year: node["chef-marketplace"]["reporting"]["cron"]["year"],
    month: node["chef-marketplace"]["reporting"]["cron"]["month"]
  )
  action reporting_partition_action
end

directory "/etc/opscode" do
  owner "opscode"
  group "opscode"
  action :create
end

template "/etc/opscode/chef-server.rb" do
  source "chef-server-aio.rb.erb"
  owner "opscode"
  group "opscode"
  action :create_if_missing
end

directory "/etc/chef-manage" do
  owner "opscode"
  group "opscode"
  action :create
end

template "/etc/chef-manage/manage.rb" do
  source "manage.rb.erb"
  owner "opscode"
  group "opscode"
  action :create_if_missing
end

["opscode", "chef-manage", "opscode-reporting"].map do |package|
  "/var/opt/#{package}/.license.accepted"
end.each do |license_file|
  directory ::File.dirname(license_file) do
    action :create
  end

  file license_file do
    action :touch
    not_if { ::File.exist?(license_file) }
  end
end
