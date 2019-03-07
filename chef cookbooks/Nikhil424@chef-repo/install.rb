# frozen_string_literal: true
#
# Cookbook Name:: solr_6
# Attributes:: install
#
# Copyright 2016, ECHO Inc
#

# Java Defaults
default['solr']['install_java'] = true
# Java version needed for this version of Solr
# (All other attributes are set at defaults but can be overridden)
default['java']['jdk_version'] = '8'

# Solr Defaults
# rubocop:disable Metrics/LineLength
default['solr']['version'] = '6.0.1'
default['solr']['url'] = "https://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/#{node['solr']['version'].split('.')[0].to_i < 4 ? 'apache-' : ''}solr-#{node['solr']['version']}.tgz"
default['solr']['dir'] = '/opt'
default['solr']['user'] = 'solr'
default['solr']['create_user'] = true
default['solr']['group'] = 'solr'
default['solr']['create_group'] = true
default['solr']['data_dir'] = '/var/solr'
default['solr']['port'] = '8983'
default['solr']['java_mem'] = '-Xms512m -Xmx512m'
default['solr']['host'] = node['fqdn']
default['solr']['timezone'] = 'UTC'
default['solr']['zk_host'] = ''
default['solr']['zk_client_timeout'] = '15000'
default['solr']['enable_remote_jmx_opts'] = false
default['solr']['rmi_port'] = '18983'
default['solr']['solr_opts'] = '-Xss256k'

default['solr']['solr_authentication_client_configurer'] = ''
default['solr']['solr_authentication_opts'] = ''

default['solr']['solr_ssl_key_store'] = ''
default['solr']['solr_ssl_key_store_password'] = ''
default['solr']['solr_ssl_trust_store'] = ''
default['solr']['solr_ssl_trust_store_password'] = ''
default['solr']['solr_ssl_need_client_auth'] = ''
default['solr']['solr_ssl_want_client_auth'] = ''

default['solr']['solr_ssl_client_key_store'] = ''
default['solr']['solr_ssl_client_key_store_password'] = ''
default['solr']['solr_ssl_client_trust_store'] = ''
default['solr']['solr_ssl_client_trust_store_password'] = ''

default['solr']['gc_log_opts'] = "-verbose:gc \
-XX:+PrintHeapAtGC \
-XX:+PrintGCDetails \
-XX:+PrintGCDateStamps \
-XX:+PrintGCTimeStamps \
-XX:+PrintTenuringDistribution \
-XX:+PrintGCApplicationStoppedTime"

default['solr']['gc_tune'] = "-XX:NewRatio=3 \
-XX:SurvivorRatio=4 \
-XX:TargetSurvivorRatio=90 \
-XX:MaxTenuringThreshold=8 \
-XX:+UseConcMarkSweepGC \
-XX:+UseParNewGC \
-XX:ConcGCThreads=4 -XX:ParallelGCThreads=4 \
-XX:+CMSScavengeBeforeRemark \
-XX:PretenureSizeThreshold=64m \
-XX:+UseCMSInitiatingOccupancyOnly \
-XX:CMSInitiatingOccupancyFraction=50 \
-XX:CMSMaxAbortablePrecleanTime=6000 \
-XX:+CMSParallelRemarkEnabled \
-XX:+ParallelRefProcEnabled"

default['solr']['deploy_url'] = 'nil'

# rubocop:enable Metrics/LineLength
