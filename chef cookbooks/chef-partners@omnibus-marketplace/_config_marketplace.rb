directory "/etc/chef-marketplace" do
  owner "root"
  group "root"
  mode "0775"
  action :nothing
end.run_action(:create)

file "/etc/chef-marketplace/marketplace.rb" do
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
end

if File.exist?("/etc/chef-marketplace/marketplace.rb")
  Marketplace.from_file("/etc/chef-marketplace/marketplace.rb")
end

node.consume_attributes("chef-marketplace" => Marketplace.save(false))

if File.exist?("/etc/chef-marketplace/chef-marketplace-running.json")
  previous_run = JSON.parse(IO.read("/etc/chef-marketplace/chef-marketplace-running.json"))
  node.consume_attributes("previous_run" => previous_run["chef-marketplace"])
end
