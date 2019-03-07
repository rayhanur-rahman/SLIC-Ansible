# Cookbook Name:: wlp
# Attributes:: default
#
# (C) Copyright IBM Corporation 2013.
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

=begin
#<
Installs WebSphere Application Server Liberty Profile from a zip file. 
This recipe is called by the `default` recipe and should not be used directly.
#>
=end

install_dir = "#{node[:wlp][:base_dir]}/wlp"

zip_uri = ::URI.parse(node[:wlp][:zip][:url])
zip_filename = ::File.basename(zip_uri.path)

if zip_uri.scheme == "file"
  zip_file = zip_uri.path
else
  zip_file = "#{Chef::Config[:file_cache_path]}/#{zip_filename}" 
  remote_file zip_file do
    source node[:wlp][:zip][:url]
    user node[:wlp][:user]
    group node[:wlp][:group]
    not_if { ::File.exists?(install_dir) }
  end
end

package 'unzip'

execute "install #{zip_filename}" do
  cwd node[:wlp][:base_dir]
  command "unzip #{zip_file}" 
  user node[:wlp][:user]
  group node[:wlp][:group]
  not_if { ::File.exists?(install_dir) }
end
