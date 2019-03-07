#
# Cookbook Name:: bcpc
# Recipe:: openstack
#
# Copyright 2013, Bloomberg Finance L.P.
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

include_recipe "bcpc::default"
include_recipe "bcpc::packages-openstack"

# python-nova is used as the canary package because it's pretty fundamental
min_version = \
  if is_liberty?
    '2:12.0.5'
  elsif is_mitaka?
    '2:13.1.2'
  else
    raise "You are attempting to install an unsupported OpenStack version."
  end

ruby_block 'evaluate-version-eligibility' do
  block do
    minimum_nova_version = Mixlib::ShellOut.new("dpkg --compare-versions $(apt-cache show --no-all-versions python-nova | egrep '^Version:' | awk '{ print $NF }') ge #{min_version}")
    cmd_result = minimum_nova_version.run_command
    fail("You must install OpenStack #{node['bcpc']['openstack_release']} #{min_version} or better. Earlier versions are not supported.") if cmd_result.error?
  end
end

ruby_block 'set-upgrade-flag-file' do
  block do
    upgrade_flag_file = '/usr/local/etc/openstack_upgrade'
    upgrade_check = Mixlib::ShellOut.new("if dpkg -s python-nova >/dev/null 2>&1; then dpkg --compare-versions $(dpkg -s python-nova | egrep '^Version:' | awk '{ print $NF }') lt $(apt-cache policy python-nova | grep Candidate | awk '{ print $NF }'); else exit 2; fi")
    upgrade_check.run_command
    # exit status 1 means comparison failed, exit status 2 means something weird happened
    # (probably shouldn't ever see exit status 2)
    if upgrade_check.error?
      ::File.unlink(upgrade_flag_file) if ::File.exist?(upgrade_flag_file)
    else
      FileUtils.touch(upgrade_flag_file)
    end
  end
end

%w{ python-novaclient
    python-cinderclient
    python-glanceclient
    python-memcache
    python-keystoneclient
    python-nova-adminclient
    python-heatclient
    python-ceilometerclient
    python-mysqldb
    python-six
    python-ldap
    python-openstackclient
}.each do |pkg|
    package pkg do
        action :install
    end
end

# remove cliff-tablib from Mitaka and beyond because it collides with built-in formatters
package 'cliff-tablib' do
  action :remove
  not_if { is_liberty? }
end

%w{control_openstack hup_openstack logwatch}.each do |script|
    template "/usr/local/bin/#{script}" do
        source "#{script}.erb"
        mode 0755
        owner "root"
        group "root"
        variables(
          lazy {
            {
              :servers => get_head_nodes
            }
          }
        )
    end
end
