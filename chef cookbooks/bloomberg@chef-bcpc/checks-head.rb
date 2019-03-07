#
# Cookbook Name:: bcpc
# Recipe:: checks-head
#
# Copyright 2016, Bloomberg Finance L.P.
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

include_recipe "bcpc::checks-common"

%w{ mysql apache }.each do |cc|
    template  "/usr/local/etc/checks/#{cc}.yml" do
        source "checks/#{cc}.yml.erb"
        owner "root"
        group "root"
        mode 00640
    end

    cookbook_file "/usr/local/bin/checks/#{cc}" do
        source "checks/#{cc}"
        owner "root"
        mode "00755"
    end
end

# remove float_ips check from head nodes (compute instances are not
# scheduled on head nodes)
%w( float_ips ).each do |cc|
  file "/usr/local/etc/checks/#{cc}.yml" do
    action :delete
  end

  file "/usr/local/bin/checks/#{cc}" do
    action :delete
  end
end


if node['bcpc']['enabled']['monitoring'] then
  cron 'check-nova' do
    home '/var/lib/zabbix' # FIXME: this sets HOME for all subsequent cronjobs
    user 'root'
    minute '*/10'
    path '/usr/local/bin:/usr/bin:/bin'
    command "zabbix_sender -c /etc/zabbix/zabbix_agentd.conf --key 'check.nova' --value `check -f timeonly nova` 2>&1 | /usr/bin/logger -p local0.notice"
  end
end
