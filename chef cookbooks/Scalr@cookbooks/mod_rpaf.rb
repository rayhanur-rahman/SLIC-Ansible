#
# Cookbook Name:: apache2
# Recipe:: python 
#
# Copyright 2008-2009, Opscode, Inc.
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

case node["platform_family"]
when "debian"
    package "libapache2-mod-rpaf"

when "rhel"
    platform_version = platform?("amazon") ? 6 : node["platform_version"].to_i
    package_url = "https://s3.amazonaws.com/scalr-labs/packages/mod_rpaf-0.6-2.el#{platform_version}.x86_64.rpm"
    path = "/tmp/#{File.basename(package_url)}"

    remote_file path do
        source package_url
    end

    rpm_package "mod_rpaf" do
        source path
        action :install
    end
    
    cookbook_file "/etc/httpd/conf.d/mod_rpaf.conf" do
        source "mod_rpaf.conf"
        mode 0755
        owner "root"
        group "root"
    end
end
