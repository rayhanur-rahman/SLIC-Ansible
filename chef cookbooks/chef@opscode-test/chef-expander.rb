node.set[:chef_expander_workers] = 2


template("chef_expander_config") do
  path    "/srv/chef/current/chef-expander/conf/chef-expander.rb"
  source  "chef-expander-config.rb.erb"
  owner   "opscode"
  group   "opscode"
  mode    "644"
  variables :rabbitmq_host      => 'localhost',
            :rabbitmq_user      => "chef",
            :rabbitmq_password  => node["apps"]["rabbitmq"]["users"]["chef"],
            :rabbitmq_vhost     => "/chef",
            :chef_expander_ps_tag => ''
end

execute("update_chef_expander_gem_bundle") do
  user    "opscode"
  group   "opscode"
  command "bundle install --deployment"
  #action  :nothing
  cwd     "/srv/chef/current/chef-expander"
end

runit_service "chef-expander"

source_code_update = resources(:deploy => 'chef')
source_code_update.notifies(:run, resources(:execute => "update_chef_expander_gem_bundle"))
source_code_update.notifies(:restart, resources(:service => "chef-expander"))

config_update = resources(:template => "chef_expander_config")
config_update.notifies(:restart, resources(:service => "chef-expander"))
