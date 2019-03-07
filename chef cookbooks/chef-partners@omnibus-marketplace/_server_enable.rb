# Add chef-server-ctl marketplace-setup shim for backwards compatability
directory "/opt/opscode/embedded/service/omnibus-ctl" do
  recursive true
end

file "/opt/opscode/embedded/service/omnibus-ctl/marketplace_setup.rb" do
  content <<'EOF'
add_command_under_category 'marketplace-setup', 'marketplace', 'Set up the Chef Server Marketplace Appliance', 2 do
  run_command("chef-marketplace-ctl setup #{ARGV[1..-1].join(' ')}")
end
EOF
  action :create
end

directory "/etc/opscode" do
  recursive true
end

template "/etc/opscode/chef-server.rb" do
  source "chef-server.rb.erb"
end
