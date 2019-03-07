bash "chef-compliance-ctl reconfigure" do
  code "chef-compliance-ctl reconfigure"
end

bash "chef-compliance-ctl stop" do
  code "chef-compliance-ctl stop"
end

compliance_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

compliance_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end

file "/etc/chef-compliance/chef-compliance.rb" do
  action :delete
end

bash "recreate complinace runit directories" do
  code "mkdir -p /opt/chef-compliance/{sv,init,service}"
end
