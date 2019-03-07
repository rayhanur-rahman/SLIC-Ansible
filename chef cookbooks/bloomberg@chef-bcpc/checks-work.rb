#
# Cookbook Name:: bcpc
# Recipe:: checks-work
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

# this recipe still gets included by head nodes so escape out if
# running on a head node
return if get_head_nodes.include?(node)

include_recipe "bcpc::checks-common"

%w{ float_ips }.each do |cc|
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

# Apache2 is now removed from work nodes, clean up the checks
# and stop Apache on currently deployed workers
%w( apache ).each do |cc|
  file "/usr/local/etc/checks/#{cc}.yml" do
    action :delete
  end

  file "/usr/local/bin/checks/#{cc}" do
    action :delete
  end
end

# co-opting this recipe to remove Apache from work nodes
service 'apache2' do
  action [:stop, :disable]
end

%w(apache2 libapache2-mod-fastcgi libapache2-mod-wsgi).each do |pkg|
  package pkg do
    action :purge
  end
end
