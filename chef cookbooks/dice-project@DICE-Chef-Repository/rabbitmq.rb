#
# Cookbook Name:: dice_deployment_service
# Recipe:: rabbitmq
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

package 'rabbitmq-server'

service 'rabbitmq-server' do
  action :nothing
end

execute 'Enable RabbitMQ we console' do
  command 'rabbitmq-plugins enable rabbitmq_management'
  notifies :restart, 'service[rabbitmq-server]'
  only_if { node['cloudify']['properties']['debug_mode'] }
end
