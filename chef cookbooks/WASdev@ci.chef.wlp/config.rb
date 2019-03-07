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
Generates a server.xml file from a hash expression.

@action create Creates or updates the server.xml file.
@action create_if_missing Creates a server.xml file only if the file does not already exist.

@section Examples
```ruby
wlp_config "/var/servers/airport/server.xml" do
  config ({
            "description" => "Airport Demo App",
            "featureManager" => {
              "feature" => [ "jsp-2.2" ]
            },
            "httpEndpoint" => {
              "id" => "defaultHttpEndpoint",
              "host" => "*",
              "httpPort" => "9080",
              "httpsPort" => "9443"
            }
  })
end
```
#>
=end
actions :create, :create_if_missing

#<> @attribute file The server.xml file to create or update.
attribute :file, :kind_of => String, :name_attribute => true

#<> @attribute config The contents of the server.xml file expressed as a hash.
attribute :config, :kind_of => [Hash], :default => nil

default_action :create
