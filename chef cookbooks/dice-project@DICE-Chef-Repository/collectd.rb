# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

logstash_udp_address =
  node['cloudify']['properties']['monitoring']['logstash_udp_address']
logstash_udp_host, logstash_udp_port = logstash_udp_address.split ':'

package 'collectd' do
  action :install
end

template '/etc/collectd/collectd.conf' do
  source 'collectd.conf.erb'
  variables host: logstash_udp_host, port: logstash_udp_port
end

service 'collectd' do
  action :restart
end
