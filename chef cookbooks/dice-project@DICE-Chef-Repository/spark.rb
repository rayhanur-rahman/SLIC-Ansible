# Sanity check
Chef::Recipe.send(:include, DmonAgent::Helper)
return if skip_installation?

dmon_master = node['cloudify']['properties']['monitoring']['dmon_address']
spark_conf_dir = node['spark']['spark-env']['SPARK_CONF_DIR']

graphite_address =
  node['cloudify']['properties']['monitoring']['logstash_graphite_address']
graphite_host, graphite_port = graphite_address.split ':'
graphite_period = node['dmon_agent']['spark']['graphite']['period']

template "#{spark_conf_dir}/metrics.properties" do
  source 'spark-metrics.tmp.erb'
  variables host: graphite_host, port: graphite_port, period: graphite_period
end

set_role 'spark' do
  dmon dmon_master
  hostname node['hostname']
end
