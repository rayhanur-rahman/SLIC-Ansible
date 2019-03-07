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
Provides operations for creating, starting, stopping, and destroying Liberty profile server instances.

@action create  Creates or updates the server instance.
@action create_if_missing  Creates a server instance only if the instance does not already exist.
@action destroy Destroys the server instance.
@action start   Creates and starts the server instance (as an OS service). 
@action stop    Stops the server instance (via an OS service).

@section Examples
```ruby
wlp_server "myInstance" do 
  config ({
            "featureManager" => {
              "feature" => [ "jsp-2.2", "jaxws-2.1" ]
            },
            "httpEndpoint" => {
              "id" => "defaultHttpEndpoint",
              "host" => "*",
              "httpPort" => "9080",
              "httpsPort" => "9443"
            },
            "application" => {
              "id" => "example",
              "name" => "example",
              "type" => "war",
              "location" => "/apps/example.war"
            }
          })
  jvmOptions [ "-Djava.net.ipv4=true" ]
  serverEnv "JAVA_HOME" => "/usr/lib/j2sdk1.7-ibm/"
  bootstrapProperties "default.http.port" => "9080", "default.https.port" => "9443"
  action :create
end

wlp_server "myInstance" do 
  clean true
  action :start
end

wlp_server "myInstance" do
  action :stop
end

wlp_server "myInstance" do
  action :destroy
end
```
#>
=end
actions :start, :stop, :create, :create_if_missing, :destroy

#<> @attribute server_name Name of the server instance.
attribute :server_name, :kind_of => String, :name_attribute => true

#<> @attribute config Configuration for the server instance. If not specified, `node[:wlp][:config][:basic]` is used as the initial configuration.
attribute :config, :kind_of => Hash, :default => nil

#<> @attribute jvmOptions Instance-specific JVM options. 
attribute :jvmOptions, :kind_of => Array, :default => []

#<> @attribute serverEnv Instance-specific server environment properties. 
attribute :serverEnv, :kind_of => Hash, :default => {}

#<> @attribute bootstrapProperties Instance-specific bootstrap properties. 
attribute :bootstrapProperties, :kind_of => Hash, :default => {}

#<> @attribute clean Clean all cached information when starting the server instance.
attribute :clean, :kind_of => [TrueClass, FalseClass], :default => false

#<> @attribute skip_umask Skip setting umask and use user default.
attribute :skip_umask, :kind_of => [TrueClass, FalseClass], :default => false

default_action :start

