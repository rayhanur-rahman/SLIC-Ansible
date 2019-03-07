#
# Cookbook Name:: dice_deployment_service
# Recipe:: dds
#
# Copyright 2016, XLAB
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
#

dice_user = node['dice_deployment_service']['app_user']
app_folder = node['dice_deployment_service']['app_folder']
app_venv = node['dice_deployment_service']['app_venv']

# Add custom ssh key if provided
directory "/home/#{dice_user}/.ssh" do
  mode 0700
  user dice_user
  group dice_user
  action :create
  only_if { node['cloudify']['properties']['ssh_key'] != '' }
end

file "/home/#{dice_user}/.ssh/authorized_keys" do
  content "#{node['cloudify']['properties']['ssh_key']}\n"
  mode 0644
  owner dice_user
  group dice_user
  only_if { node['cloudify']['properties']['ssh_key'] != '' }
end

# Installation of system packages
package ['npm', 'git']

# Nodejs fixups
link '/usr/bin/node' do
  to '/usr/bin/nodejs'
  not_if { ::File.file?('/usr/bin/node') }
end

# Ugly fix for npm stupidity (https://github.com/npm/npm/issues/20191)
execute 'Disable strict ssl checking in npm' do
  command 'npm config set strict-ssl false'
end

# Install dice deployment service files
dds_tar = "#{Chef::Config[:file_cache_path]}/dds.tar.gz"
dds_folder = "#{Chef::Config[:file_cache_path]}/dds"
dds_tar_source =
  if node['cloudify']['runtime_properties'].key?('dds_tarball')
    "file:///#{node['cloudify']['runtime_properties']['dds_tarball']}"
  else
    node['cloudify']['properties']['sources']
  end
remote_file 'Obtain deployment service sources' do
  path dds_tar
  source dds_tar_source
end

poise_archive dds_tar do
  destination dds_folder
end

execute 'Move package to final place' do
  command "mv #{dds_folder}/dice_deploy_django #{app_folder}"
end

execute 'Fix application permissions' do
  command "chown -R #{dice_user}:#{dice_user} #{app_folder}"
end

# Create virtualenv and install packages
pip_requirements "#{app_folder}/requirements.txt" do
  virtualenv app_venv
  user dice_user
  group dice_user
end

# Install bower and packages
execute 'Install Bower' do
  command 'npm install -g bower'
end

# TODO: Next recipe is really bad, but bower is not meant to be run on
# deployment server. We need to prepare proper package with asserts already
# compiled.
execute 'Install bower packages' do
  command 'bower install --allow-root'
  cwd app_folder
end

cfy_crt_source = node['cloudify']['runtime_properties'].fetch('cfy_crt', nil)
cfy_crt_target = '/etc/ssl/certs/cfy.crt'

remote_file cfy_crt_target do
  source "file://#{cfy_crt_source}"
  not_if { cfy_crt_source.nil? }
end

# Install postgres connector
python_package 'psycopg2' do
  virtualenv app_venv
  user dice_user
  group dice_user
end

# Create local settings
template "#{app_folder}/dice_deploy/local_settings.py" do
  source 'local_settings.py.erb'
  variables(
    manager_url: node['cloudify']['properties']['manager'],
    manager_username: node['cloudify']['properties']['manager_user'],
    manager_cacert: cfy_crt_source.nil? ? nil : cfy_crt_target,
    manager_protocol: node['cloudify']['properties']['manager_protocol'],
    manager_password: node['cloudify']['properties']['manager_pass'],
    db_name: node['dice_deployment_service']['db_name']
  )
  owner dice_user
  group dice_user
end

# Create super user
suser = node['cloudify']['properties']['superuser_username']
spass = node['cloudify']['properties']['superuser_password']
smail = node['cloudify']['properties']['superuser_email']
execute 'Create super user' do
  command "bash run.sh reset #{suser} #{spass} #{smail}"
  cwd app_folder
  user dice_user
  group dice_user
  environment 'PATH' => "#{app_venv}/bin:#{ENV['PATH']}"
end

# Collect static files
execute 'Collect static files' do
  command 'python manage.py collectstatic --no-input'
  cwd app_folder
  user dice_user
  group dice_user
  environment 'PATH' => "#{app_venv}/bin:#{ENV['PATH']}"
end
