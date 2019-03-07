plugin "chef-marketplace" do
  enabled_by_default true
  cookbook_path "/opt/chef-marketplace/embedded/server-plugin-cookbooks"
  config_extension_path "/var/opt/opscode/chef-marketplace/config.rb"
end
