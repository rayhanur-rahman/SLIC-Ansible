#
# Cookbook Name:: enterprise
# Resource:: pg_database
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
property :database, String, name_property: true
property :owner, String
property :template, String, default: 'template0'
property :encoding, String, default: 'UTF-8'
property :username, String
property :password, String
property :host, String

# NOTE:
#
# Uses the value of node[project_name]['postgresql']['username'] as
# the user to run the database-creation psql command

action :create do
  project_name = node['enterprise']['name']

  ENV['PGHOST'] = new_resource.host if new_resource.host
  ENV['PGUSER'] = new_resource.username if new_resource.username
  ENV['PGPASSWORD'] = new_resource.password if new_resource.password

  execute "create_database_#{new_resource.database}" do
    command createdb_command
    user node[project_name]['postgresql']['username']
    not_if { database_exist? }
    retries 30
  end
end

action_class do
  def createdb_command
    [].tap do |cmd|
      cmd << 'createdb'
      cmd << "--template #{new_resource.template}"
      cmd << "--encoding #{new_resource.encoding}"
      cmd << "--owner #{new_resource.owner}" if new_resource.owner
      cmd << new_resource.database
    end.join(' ')
  end

  def database_exist?
    project_name = node['enterprise']['name']

    cmd = []
    cmd << 'psql'
    cmd << '--dbname template1 --tuples-only'
    cmd << %(--command "SELECT datname FROM pg_database WHERE datname='#{new_resource.database}';")
    cmd << "| grep #{new_resource.database}"
    cmd = cmd.join(' ')

    s = Mixlib::ShellOut.new(cmd,
                             user: node[project_name]['postgresql']['username'])
    s.run_command
    s.exitstatus == 0
  end
end
