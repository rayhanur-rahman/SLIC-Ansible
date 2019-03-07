property :username, String, name_property: true
property :password, String, required: true
property :superuser, [TrueClass, FalseClass], default: false
property :admin_username, String, required: false
property :admin_password, String, required: false
property :host, String, required: false

#
# Cookbook Name:: enterprise
# Resource:: pg_user
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
# NOTE:
#
# Uses the value of node[project_name]['postgresql']['username'] as
# the user to run the user-creation psql command

action :create do
  project_name = node['enterprise']['name']

  ENV['PGHOST'] = new_resource.host if new_resource.host
  ENV['PGUSER'] = new_resource.admin_username if new_resource.admin_username
  ENV['PGPASSWORD'] = new_resource.admin_password if new_resource.admin_password

  execute "create_postgres_user_#{new_resource.username}" do
    command create_user_query_command
    user node[project_name]['postgresql']['username']
    not_if { user_exist? }
    retries 30
  end
end

action_class do
  def create_user_query_command
    [].tap do |ary|
      ary << 'psql'
      ary << '--dbname template1 --command'
      ary << %("CREATE USER #{new_resource.username} WITH)
      ary << %(SUPERUSER) if new_resource.superuser
      ary << %(ENCRYPTED PASSWORD '#{new_resource.password}';")
    end.join(' ')
  end

  def user_exist?
    project_name = node['enterprise']['name']

    command = [].tap do |ary|
      ary << 'psql'
      ary << '--dbname template1'
      ary << '--tuples-only'
      ary << %(--command "SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.username}';")
      ary << "| grep #{new_resource.username}"
    end.join(' ')

    s = Mixlib::ShellOut.new(command,
                             user: node[project_name]['postgresql']['username'])
    s.run_command
    s.exitstatus == 0
  end
end
