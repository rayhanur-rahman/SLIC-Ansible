# Cookbook Name:: bcpc
# Recipe:: ceph-cleanup
#
# Copyright 2017 Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Transitional recipe to clean up deprecated ceph-related things


obsolete_ceph_cronjobs = [
  'set-rgw-quota',
  'check-rgw'
]

obsolete_ceph_cronjobs.each do |ceph_cronjob|
  cron "#{ceph_cronjob}" do
    action :delete
  end
end

obsolete_ceph_files = [
  '/usr/local/etc/checks/rgw.yml',
  '/usr/local/bin/set-rgw-quota.py',
  '/usr/local/etc/rgw-quota.yml',
  '/usr/local/bin/radosgw_check.py',
  '/etc/zabbix/zabbix_agentd.d/zabbix-rgw.conf'
]

obsolete_ceph_files.each do |ceph_file|
  file "#{ceph_file}" do
    action :delete
  end
end

# delete the compromised Ceph signing key (17ED316D)
bash 'remove-old-ceph-key' do
  code 'apt-key del 17ED316D'
  only_if 'apt-key list | grep -q 460F3994 && apt-key list | grep -q 17ED316D'
end

service 'radosgw-all' do
  provider Chef::Provider::Service::Upstart
  action :stop
end

package 'radosgw' do
  action :purge
end

obsolete_ceph_keys = [
  'client.bootstrap-rgw',
  'client.radosgw.gateway'
]

obsolete_ceph_keys.each do |ceph_key|
  bash "remove-ceph-keys-#{ceph_key}" do
    code "ceph --name client.admin --keyring /etc/ceph/ceph.client.admin.keyring auth del #{ceph_key}"
    only_if "ceph --name client.admin --keyring /etc/ceph/ceph.client.admin.keyring auth list | grep \"^#{ceph_key}$\""
  end
end

unused_ceph_pools = [
  '.rgw',
  '.rgw.control',
  '.rgw.gc',
  '.rgw.root',
  '.users.uid',
  '.users.email',
  '.users',
  '.usage',
  '.log',
  '.intent-log',
  '.rgw.buckets',
  '.rgw.buckets.index',
  '.rgw.buckets.extra'
]

unused_ceph_pools.each do |pool|
  bash "remove-ceph-pool-#{pool}" do
    code "rados rmpool #{pool} #{pool} --yes-i-really-really-mean-it"
    only_if "rados lspools | grep \"#{pool}$\""
  end
end

directory '/var/lib/ceph/radosgw' do
  action :delete
  recursive true
end
