#
# Cookbook Name:: enterprise
# Resource:: pg_cluster
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
# Initialize a PostgreSQL database cluster.  Ensures the data
# directory exists, runs initdb, and sets up postgresql.conf and
# pg_hba.conf files.
#
# Does NOT signal for the cluster to start; that's your responsibility
# if you want it.

# NOTE:
#
# Uses the value of node[project_name]['postgresql']['username'] as
# the user to run the initdb command.  This user will also be the
# owner of the data directory and configuration files.
#
# Additionally, the node[project_name]['postgresql'] hash is used
# for configuration file template creation.

property :data_dir, String, name_property: true
property :encoding, String, default: 'SQL_ASCII'

action :init do
  project_name = node['enterprise']['name']

  # Ensure the data directory exists first!
  directory new_resource.data_dir do
    owner node[project_name]['postgresql']['username']
    mode '0700'
    recursive true
  end

  # Initialize the cluster
  execute "initialize_cluster_#{new_resource.data_dir}" do
    command "initdb --pgdata #{new_resource.data_dir} --locale C --encoding #{new_resource.encoding}"
    user node[project_name]['postgresql']['username']
    not_if { ::File.exist?(::File.join(new_resource.data_dir, 'PG_VERSION')) }
  end

  # Create configuration files
  ['postgresql.conf', 'pg_hba.conf'].each do |config_file|
    template ::File.join(new_resource.data_dir, config_file) do
      owner node[project_name]['postgresql']['username']
      mode '0644'
      variables(node[project_name]['postgresql'].to_hash)
    end
  end
end
