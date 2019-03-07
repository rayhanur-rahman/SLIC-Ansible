# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

dmon_master = node['cloudify']['properties']['monitoring']['dmon_address']

set_role 'cassandra' do
  dmon dmon_master
  hostname node['hostname']
end

cookbook_file '/etc/collectd/collectd.conf.d/cassandra.conf' do
  source 'collectd-cassandra.conf'
  mode '0644'
end

cookbook_file '/usr/share/collectd/dice.db' do
  source 'dice.db'
  mode '0644'
end

service 'collectd' do
  action :restart
end
