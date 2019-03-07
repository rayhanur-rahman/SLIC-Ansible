# Cookbook: rundeck-server
# Recipe:   install_cli
# Description: This should be ran if using Rundeck 7.x+
# See: http://rundeck.org/docs/upgrading/index.html#cli-tools-are-gone
# Note: This must be Java 8 or greater
include_recipe 'java' if node['rundeck_server']['install_java']

package 'rundeck-cli' do
  version node['rundeck_server']['cli']['version']
end

directory ::File.join(node['rundeck_server']['basedir'], '.rd') do
  owner 'rundeck'
  group 'rundeck'
end

template 'rd.conf' do
  path ::File.join(node['rundeck_server']['basedir'], '.rd', 'rd.conf')
  variables(properties: node['rundeck_server']['cli']['config'])
  action :create
  sensitive true
  owner 'rundeck'
  group 'rundeck'
end
