#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: couchdb
# Recipe:: source
#
# Copyright 2010, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if node['platform_family'] == 'rhel' && node['platform_version'].to_f < 6.0
  Chef::Log.warn('RHEL/CentOS < 6.0 is unsupported by couchdb::source')
end

couchdb_tar_gz = "apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"
compile_flags = ''
dev_pkgs = []

case node['platform_family']
when 'debian'
  dev_pkgs << 'libicu-dev'
  dev_pkgs << 'libcurl4-openssl-dev'
  dev_pkgs << value_for_platform(
    'debian' => { 'default' => 'libmozjs-dev' },
    'ubuntu' => {
      '10.04' => 'xulrunner-dev',
      '14.04' => 'libmozjs185-dev',
      'default' => 'libmozjs-dev'
    }
  )
when 'rhel', 'fedora'
  include_recipe 'yum-epel'

  dev_pkgs += %w{
    which make gcc gcc-c++ js-devel libtool
    libicu-devel openssl-devel curl-devel
  }

  # awkwardly tell ./configure where to find Erlang's headers
  bitness = node['kernel']['machine'] =~ /64/ ? 'lib64' : 'lib'
  compile_flags = "--with-erlang=/usr/#{bitness}/erlang/usr/include"
end

include_recipe 'erlang::esl' if node['couch_db']['install_erlang']

dev_pkgs.each do |pkg|
  package pkg
end

ark couchdb_tar_gz do
  url node['couch_db']['src_mirror']
  checksum node['couch_db']['src_checksum']
  version node['couch_db']['src_vesion']
  action :install_with_make
  if node['platform_family'] == 'rhel' && node['couch_db']['install_erlang']
    autoconf_opts [ '--with-erlang=/usr/lib/erlang/usr/include' ]
  end
end

user 'couchdb' do
  home '/usr/local/var/lib/couchdb'
  comment 'CouchDB Administrator'
  supports :manage_home => false
  system true
end

%w{ var/lib/couchdb var/log/couchdb var/run/couchdb etc/couchdb }.each do |dir|
  directory "/usr/local/#{dir}" do
    owner 'couchdb'
    group 'couchdb'
    mode '0770'
    recursive true
  end
end

template '/usr/local/etc/couchdb/local.ini' do
  source 'local.ini.erb'
  owner 'couchdb'
  group 'couchdb'
  mode 0660
  variables(
    :config => node['couch_db']['config']
  )
  notifies :restart, 'service[couchdb]'
end

if node['platform'] == 'ubuntu'
  template '/etc/init/couchdb.conf' do
    action :create
    source 'couchdb.upstart.erb'
    owner 'root'
    group 'root'
    mode '0755'
    notifies :restart, 'service[couchdb]', :delayed
  end
else
  cookbook_file '/etc/init.d/couchdb' do
    source 'couchdb.init'
    owner 'root'
    group 'root'
    mode '0755'
  end
end

service 'couchdb' do
  if node['platform'] == 'ubuntu'
    provider Chef::Provider::Service::Upstart
  end
  supports [:restart, :status]
  action [:enable, :start]
end
