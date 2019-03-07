#
# Cookbook Name:: utils
# Attributes:: solr
#
# Copyright 2013, Mediacurrent
#
# All rights reserved - Do Not Redistribute

include_attribute "java"
include_attribute "hipsnip-solr"
include_attribute "hipsnip-jetty"

node['jetty']['port'] = 8983

default['utils']['solr']['drupal_module_path'] = "#{node[:docroot]}/sites/all/modules/apachesolr"

if node['solr']['version'].start_with?('4')
  default['utils']['solr']['config_dir'] = 'collection1/conf'
  default['utils']['solr']['drupal_conf_dir'] = 'solr-conf/solr-4.x'

  node['java']['jdk_version'] = '7'
  node['jetty']['version'] = '9.0.6.v20130930'
  node['jetty']['link'] = 'http://eclipse.org/downloads/download.php?file=/jetty/9.0.6.v20130930/dist/jetty-distribution-9.0.6.v20130930.tar.gz&r=1'
  node['jetty']['checksum'] = 'c35c6c0931299688973e936186a6237b69aee2a7912dfcc2494bde9baeeab58f'
else
  default['utils']['solr']['config_dir'] = 'conf'
  default['utils']['solr']['drupal_conf_dir'] = 'solr-conf/solr-3.x'
end

default['utils']['solr']['solr_config_files'] = [
  'protwords.txt',
  'schema.xml',
  'schema_extra_fields.xml',
  'schema_extra_types.xml',
  'solrconfig.xml',
  'solrconfig_extra.xml',
  'solrcore.properties'
]
