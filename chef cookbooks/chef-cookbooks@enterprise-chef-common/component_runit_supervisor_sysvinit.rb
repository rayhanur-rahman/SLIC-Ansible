#
# Cookbook Name:: enterprise
# Resource:: component_runit_supervisor
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
include ComponentRunitSupervisorResourceMixin

provides :component_runit_supervisor, platform_family: 'suse' do |node|
  node['platform_version'].to_i == 11
end
provides :component_runit_supervisor, platform: 'debian'
provides :component_runit_supervisor, platform_family: 'rhel' do |node|
  node['platform_version'].to_i == 5
end

action :create do
  execute "echo '#{svdir_line}' >> /etc/inittab" do
    not_if "grep '#{svdir_line}' /etc/inittab"
    notifies :run, 'execute[init q]', :immediately
  end

  execute 'init q' do
    action :nothing
  end
end

action :delete do
  Dir["#{new_resource.install_path}/service/*"].each do |svc|
    execute "#{new_resource.install_path}/embedded/bin/sv stop #{svc}" do
      retries 5
      only_if { ::File.exist? "#{new_resource.install_path}/embedded/bin/sv" }
    end
  end

  ruby_block 'remove inittab entry' do
    block do
      f = Chef::Util::FileEdit.new '/etc/inittab'
      f.search_file_delete svdir_line
      f.write_file
    end
    only_if "grep '#{svdir_line}' /etc/inittab"
    notifies :run, 'execute[init q]', :immediately
    notifies :run, 'execute[pkill -HUP -P 1 runsv$]', :immediately
  end

  execute 'init q' do
    action :nothing
  end

  # To avoid stomping on runsv's owned by a different runsvdir
  # process, kill any runsv process that has been orphaned, and is
  # now owned by init (process 1).
  execute 'pkill -HUP -P 1 runsv$' do
    action :nothing
  end
end

action_class do
  def svdir_line
    "#{new_resource.sysvinit_id}:123456:respawn:#{new_resource.install_path}/embedded/bin/runsvdir-start"
  end
end
