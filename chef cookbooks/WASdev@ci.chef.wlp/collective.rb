# Cookbook Name:: wlp
# Attributes:: default
#
# (C) Copyright IBM Corporation 2014.
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
Provides operations for creating, joining, replicating, and removing Liberty profile servers from a collective.

@action create  Creates the initial collective controller for the Liberty collective.
@action join    Joins a Liberty server to the collective managed by the specified collective controller.
@action replicate Destroys the server instance.
@action remove   Creates and starts the server instance (as an OS service). 

@section Examples
```ruby
Fill me in!
```
#>
=end
actions :create, :join, :replicate, :remove

#<> @attribute server_name Name of the server instance to operate on
attribute :server_name, :kind_of => String, :name_attribute => true

#<> @attribute keystorePassword The keystore password to set when creating the collective SSL configuration.
attribute :keystorePassword, :kind_of => String, :default => nil

#<> @attribute host The host of the collective controller to join to, replicate from or remove from. If not specified, the controller host will be looked up from the Chef server.
attribute :host, :kind_of => String, :default => nil

#<> @attribute port The port of the collective controller to join to, replicate from or remove from. If not specified, the controller port will be looked up from the Chef server.
attribute :port, :kind_of => String, :default => nil

#<> @attribute user An Administrative user name. The join, replicate and remove actions require an authenticated user.
attribute :user, :kind_of => String, :default => nil

#<> @attribute password The Administrative user's password. The join, replicate and remove actions require an authenticated user.
attribute :password, :kind_of => String, :default => nil

#<> @attribute admin_user Name of the quickStartSecurity admin userid
attribute :admin_user, :kind_of => String, :default => nil

#<> @attribute admin_password Name of the quickStartSecurity admin password
attribute :admin_password, :kind_of => String, :default => nil

default_action :create

