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
Adds, removes, and sets bootstrap properties for a particular server instance.

@action add    Adds properties to the bootstrap.properties file. Other existing properties in the file are preserved.
@action remove Removes properties from the bootstrap.properties file. Other existing properties in the file are preserved.
@action set    Set properties in the bootstrap.properties file. Other existing properties in the file are not preserved.

@section Examples
```ruby
wlp_bootstrap_properties "add to bootstrap.properties" do
  server_name "myInstance"
  properties "com.ibm.ws.logging.trace.file.name" => "trace.log"
  action :add
end

wlp_bootstrap_properties "remove from bootstrap.properties" do
  server_name "myInstance"
  properties [ "com.ibm.ws.logging.trace.file.name" ]
  action :remove
end

wlp_bootstrap_properties "set bootstrap.properties" do
  properties "default.http.port" => "9081", "default.https.port" => "9444"
  action :set
end
```
#>
=end
actions :add, :remove, :set

#<> @attribute server_name Name of the server instance.
attribute :server_name, :kind_of => String, :default => nil

#<> @attribute properties The properties to add, remove, or set. Must be specified as a hash when adding or setting and as an array when removing.
attribute :properties, :kind_of => [Hash, Array], :default => nil

default_action :set

