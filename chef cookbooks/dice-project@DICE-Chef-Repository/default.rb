# Cookbook Name:: cassandra
# Attribute:: default
#
# Copyright 2016, XLAB d.o.o.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['cassandra']['install_dir'] = '/usr/share/cassandra'
default['cassandra']['group'] = 'cassandra'
default['cassandra']['user'] = 'cassandra'

default['cassandra']['tarball'] =
  'http://www-eu.apache.org/dist/cassandra/3.0.16/'\
  'apache-cassandra-3.0.16-bin.tar.gz'
default['cassandra']['checksum'] =
  '632cc817828499b94045ae68484e91f5d08a90c24908dd99d94c1972d8b29a39'

default['cassandra']['connection_retries'] = 12
default['cassandra']['connection_sleep_seconds'] = 5

# Configuration - folders
default['cassandra']['yaml']['data_file_directories'] = [
  '/var/lib/cassandra/data'
]
default['cassandra']['yaml']['saved_caches_directory'] =
  '/var/lib/cassandra/saved_caches'
default['cassandra']['yaml']['commitlog_directory'] =
  '/var/lib/cassandra/commitlog'
default['cassandra']['yaml']['hints_directory'] =
  '/var/lib/cassandra/hints'

# Default configuration
default['cassandra']['yaml']['cluster_name'] = 'Sample Cluster'
default['cassandra']['yaml']['num_tokens'] = 256
default['cassandra']['yaml']['commitlog_sync'] = 'periodic'
default['cassandra']['yaml']['commitlog_sync_period_in_ms'] = 10_000
default['cassandra']['yaml']['partitioner'] =
  'org.apache.cassandra.dht.Murmur3Partitioner'
default['cassandra']['yaml']['endpoint_snitch'] = 'GossipingPropertyFileSnitch'
default['cassandra']['yaml']['auto_bootstrap'] = false
default['cassandra']['yaml']['start_native_transport'] = true
default['cassandra']['yaml']['native_transport_port'] = 9042

# Settings that should be set by cloudify (present here only for documentation
# purposes)

# default['cassandra']['yaml']['listen_address'] = 'IP address of the machine'
# default['cassandra']['yaml']['rpc_address'] = 'IP address of the machine'
# default['cassandra']['yaml']['seed_provider'] = [{
#   'class_name': 'org.apache.cassandra.locator.SimpleSeedProvider',
#   'parameters': [{
#     'seeds': '172.16.0.11,172.16.0.12'
#   }]
# }]
