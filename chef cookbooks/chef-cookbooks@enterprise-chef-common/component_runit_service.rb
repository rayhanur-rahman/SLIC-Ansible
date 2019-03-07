#
# Cookbook Name:: enterprise
# Resource:: component_runit_service
#
# Copyright:: 2018, Chef Software, Inc.
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
#
# A runit service wrapper for a chef component within an omnibus project
#
resource_name :component_runit_service

# :component is the name of the component/service of the project for which
# this resource will manage a runit definition
property :component, String, name_property: true

# :package is the project name and is used as the key into which part of the
# node attributes will be referenced for package+component configuration
# because add-ons have different package names
# e.g. :package => 'reporting' or :package => 'manage'
property :package, String, default: 'private_chef'

property :log_directory, String # where the runit service will manage itself
property :svlogd_size, Integer # log rotation : a size limit for log files
property :svlogd_num, Integer # log rotation : the number of log files to keep
property :ha, [TrueClass, FalseClass] # is this a highly-available service?
property :control, Array # control signal overrides for runit and runsv

# :runit_attributes - optionally set other properties on the runit_service
# resource that are not explicitly supported by this resource
property :runit_attributes, Hash, default: {}

action :enable do
  log_directory = new_resource.log_directory || node[new_resource.package][new_resource.component]['log_directory']
  svlogd_size = new_resource.svlogd_size || node[new_resource.package][new_resource.component]['log_rotation']['file_maxbytes']
  svlogd_num = new_resource.svlogd_num || node[new_resource.package][new_resource.component]['log_rotation']['num_to_keep']

  # runit resources don't support reloading the log service as an action :(
  execute "restart_#{new_resource.component}_log_service" do
    command "#{node['runit']['sv_bin']} restart #{node['runit']['sv_dir']}/#{new_resource.component}/log"
    action :nothing
  end

  template "#{log_directory}/config" do
    source 'config.svlogd'
    cookbook 'enterprise'
    mode '0644'
    owner 'root'
    group 'root'
    notifies :run, "execute[restart_#{new_resource.component}_log_service]"
    variables(
      svlogd_size: svlogd_size,
      svlogd_num: svlogd_num
    )
  end

  runit_service new_resource.component do
    action :enable
    retries 20
    control new_resource.control if new_resource.control
    options(
      log_directory: log_directory
    )
    new_resource.runit_attributes.each do |attr_name, attr_value|
      send(attr_name.to_sym, attr_value)
    end
  end

  # Keepalive management
  #
  # Our keepalived setup knows which services it must manage by
  # looking for a 'keepalive_me' sentinel file in the service's
  # directory.
  if EnterpriseChef::Helpers.ha?(node)
    # We need special handling for the ha param, as it's a boolean and
    # could be false, so we explicitly check for nil?
    is_keepalive_service = if new_resource.ha.nil?
                             node[new_resource.package][new_resource.component]['ha']
                           else
                             new_resource.ha
                           end
    file "#{node['runit']['sv_dir']}/#{new_resource.component}/keepalive_me" do
      action is_keepalive_service ? :create : :delete
    end

    file "#{node['runit']['sv_dir']}/#{new_resource.component}/down" do
      action is_keepalive_service ? :create : :delete
    end
  end
end

action :down do
  runit_service new_resource.component do
    action :stop
  end
end

[:start, :restart, :stop, :reload, :disable].each do |action_name|
  action action_name do
    runit_service new_resource.component do
      action action_name
    end
  end
end
