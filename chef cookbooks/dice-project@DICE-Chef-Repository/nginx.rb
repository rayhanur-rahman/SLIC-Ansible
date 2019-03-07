#
# Cookbook Name:: dice_deployment_service
# Recipe:: nginx
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

app_folder = node['dice_deployment_service']['app_folder']
app_socket = node['dice_deployment_service']['app_socket']
upload_limit = node['dice_deployment_service']['upload_limit']

dds_crt = node['cloudify']['runtime_properties'].fetch('dds_crt', nil)
dds_key = node['cloudify']['runtime_properties'].fetch('dds_key', nil)

package 'nginx'

service 'nginx' do
  action :nothing
end

if dds_crt.nil? || dds_key.nil?
  ssl_cnf = "#{Chef::Config[:file_cache_path]}/ssl.cnf"

  template ssl_cnf do
    source 'ssl.cnf.erb'
    variables ip: node['cloudify']['runtime_properties']['external_ip']
  end

  bash 'Create certificate' do
    code <<-EOF
      openssl req -new -nodes -x509 -newkey rsa:2048 -sha256 -days 730 \
        -config #{ssl_cnf} \
        -out /etc/ssl/certs/dds.crt \
        -keyout /etc/ssl/private/dds.key
      EOF
  end
else
  remote_file '/etc/ssl/certs/dds.crt' do
    source "file://#{dds_crt}"
  end

  remote_file '/etc/ssl/private/dds.key' do
    source "file://#{dds_key}"
  end
end

template '/etc/nginx/sites-available/dice-deployment-service' do
  source 'dice-deployment-service.erb'
  variables(
    app_folder: app_folder,
    app_socket: app_socket,
    upload_limit: upload_limit
  )
  notifies :restart, 'service[nginx]'
end

link '/etc/nginx/sites-enabled/default' do
  to '/etc/nginx/sites-available/default'
  action :delete
  notifies :restart, 'service[nginx]'
end

link '/etc/nginx/sites-enabled/dice-deployment-service' do
  to '/etc/nginx/sites-available/dice-deployment-service'
  notifies :restart, 'service[nginx]'
end
