directory "/etc/chef-compliance" do
  owner "root"
  group "root"
  action :create
end

template "/etc/chef-compliance/chef-compliance.rb" do
  source "chef-compliance.rb.erb"
  owner "root"
  group "root"
  action :create_if_missing
end

license_file = "/var/opt/chef-compliance/.license.accepted"

directory ::File.dirname(license_file) do
  action :create
end

file license_file do
  action :touch
  not_if { ::File.exist?(license_file) }
end
