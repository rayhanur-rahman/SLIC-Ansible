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
Adds, removes, and sets environment properties in installation-wide or instance-specific server.env file.

@action add    Adds environment properties to a server.env file. Other existing properties in the file are preserved.
@action remove Removes environment properties from a server.env file. Other existing properties in the file are preserved.
@action set    Set environment properties in a server.env file. Other existing properties in the file are not preserved.

@section Examples
```ruby
wlp_server_env "add to instance-specific server.env" do
  server_name "myInstance"
  properties "JAVA_HOME" => "/usr/lib/j2sdk1.7-ibm/"
  action :add
end

wlp_server_env "remove from instance-specific server.env" do
  server_name "myInstance"
  properties [ "JAVA_HOME" ]
  action :remove
end

wlp_server_env "set installation-wide server.env" do
  properties "WLP_USER_DIR" => "/var/wlp"
  action :set
end

wlp_server_env "remove from installation-wide server.env" do
  properties [ "WLP_USER_DIR" ]
  action :remove
end
```
#>
=end
actions :add, :remove, :set

#<> @attribute server_name If specified, the server.env file in the specified server instance is updated. Otherwise, the installation-wide server.env file is updated.
attribute :server_name, :kind_of => String, :default => nil

#<> @attribute properties The properties to add, set, or remove. Must be specified as a hash when adding or setting, and as an array when removing.
attribute :properties, :kind_of => [Hash, Array], :default => nil

default_action :set

