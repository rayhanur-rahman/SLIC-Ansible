# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

apt_repository 'logstash-forwarder' do
  uri 'http://packages.elasticsearch.org/logstashforwarder/debian'
  components ['main']
  distribution 'stable'
  key 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch'
end

package 'logstash-forwarder' do
  action :install
end

crt = node['cloudify']['properties']['monitoring']['logstash_lumberjack_crt']
file '/etc/ssl/certs/logstash-forwarder.crt' do
  content crt
  action :create
end

directory '/etc/logstash-forwarder.conf.d'

server =
  node['cloudify']['properties']['monitoring']['logstash_lumberjack_address']
template '/etc/logstash-forwarder.conf.d/net.conf' do
  source 'logstash-forwarder.conf.erb'
  action :create
  variables servers: [server]
end

cookbook_file '/etc/init/lsf.conf' do
  source 'lsf.conf'
end
