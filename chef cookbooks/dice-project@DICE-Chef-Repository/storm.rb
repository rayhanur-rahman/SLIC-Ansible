# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

template '/etc/default/dmon-agent.d/storm' do
  source 'service-vars.erb'
  variables env_vars: {
    'STORM_VERSION' => '1.0',
    'STORM_LOG' => node['storm']['log_dir']
  }
end

set_role 'storm' do
  dmon node['cloudify']['properties']['monitoring']['dmon_address']
  hostname node['hostname']
end
