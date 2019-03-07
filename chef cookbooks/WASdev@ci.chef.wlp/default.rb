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

#<> User name under which the server is installed and runs.
default[:wlp][:user] = "wlp"

#<> Group name under which the server is installed and runs.
default[:wlp][:group] = "wlpadmin"

#<
# Use the `java` cookbook to install Java. If Java is installed using a
# different method override it to `false`, in which case, the Java executables
# must be available on the __PATH__.
#>
default[:wlp][:install_java] = true

#<> Base installation directory.
default[:wlp][:base_dir] = "/opt/was/liberty"

#<> User directory (wlp.user.dir). Set to 'nil' to use default location.
default[:wlp][:user_dir] = nil

#<> Installation method. Set it to 'archive' or 'zip'.
default[:wlp][:install_method] = 'archive'

#<
#  Location of the Yaml file containing the URLs of the 'archive' install file
#  for the latest release and latest beta.
#>
default[:wlp][:archive][:version_yaml] = "http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml"

#<> Use the beta instead of the release.
default[:wlp][:archive][:use_beta] = false

#<
#  URL location of the runtime archive. Overrides the location in the Yaml file.
#>
default[:wlp][:archive][:runtime][:url] = nil

#<
#  URL location of the extended archive. Only used if the archive runtime url
#  is set.
#>
default[:wlp][:archive][:extended][:url] = nil

#<
#  URL location of the extras archive. Only used if
#  `node[:wlp][:archive][:runtime][:url]` is set.
#>
default[:wlp][:archive][:extras][:url] = nil

#<> Controls whether the extended archive is downloaded and installed.
default[:wlp][:archive][:extended][:install] = true

#<> Controls whether the extras archive is downloaded and installed.
default[:wlp][:archive][:extras][:install] = false

#<> Base installation directory of the extras archive.
default[:wlp][:archive][:extras][:base_dir] = "#{node[:wlp][:base_dir]}/extras"

#<
#  Accept license terms when doing archive-based installation.
#  Must be set to `true` or the installation fails.
#>
default[:wlp][:archive][:accept_license] = false

#<
#  URL location for a zip file containing Liberty profile installation files.
#  Must be set if `node[:wlp][:install_method]` is set to `zip`.
#>
default[:wlp][:zip][:url] = nil

#<> Controls whether install_feature and download_feature uses the online liberty repository
default[:wlp][:repository][:liberty] = true

#<> Sets a list of URLs for hosted or local asset repository used by install_feature and download_feature
default[:wlp][:repository][:urls] = []

#<
#  Defines a basic server configuration when creating server instances using
#  the `wlp_server` resource.
#>
default[:wlp][:config][:basic] = {
  "featureManager" => {
    "feature" => [ "jsp-2.2" ]
  },
  "httpEndpoint" => {
    "id" => "defaultHttpEndpoint",
    "host" => "*",
    "httpPort" => "9080",
    "httpsPort" => "9443"
  }
}
