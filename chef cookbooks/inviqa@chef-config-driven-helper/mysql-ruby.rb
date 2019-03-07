include_recipe 'mysql::client'
include_recipe 'build-essential'

gem_package "mysql" do
  gem_binary File.join(RbConfig::CONFIG["bindir"], 'gem')
  action :install
end
