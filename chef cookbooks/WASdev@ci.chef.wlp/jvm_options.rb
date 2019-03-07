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
Adds, removes, and sets JVM options in an installation-wide or instance-specific jvm.options file.

@action add    Adds JVM options to a jvm.options file. Other existing options in the file are preserved. 
@action remove Removes JVM options from a jvm.options file. Other existing options in the file are preserved. 
@action set    Sets JVM options in a jvm.options file. Other existing options are not preserved. 

@section Examples
```ruby
wlp_jvm_options "add to instance-specific jvm.options" do
  server_name "myInstance"
  options [ "-Djava.net.ipv4=true" ]
  action :add
end

wlp_jvm_options "remove from instance-specific jvm.options" do
  server_name "myInstance"
  options [ "-Djava.net.ipv4=true" ]
  action :remove
end

wlp_jvm_options "add to installation-wide jvm.options" do
  options [ "-Xmx1024m" ]
  action :add
end

wlp_jvm_options "remove from installation-wide jvm.options" do
  options [ "-Xmx1024m" ]
  action :remove
end
```
#>
=end
actions :add, :remove, :set

#<> @attribute server_name If specified, the jvm.options file in the specified server instance is updated. Otherwise, the installation-wide jvm.options file is updated.
attribute :server_name, :kind_of => String, :default => nil

#<> @attribute options The JVM options to add, set, or remove.
attribute :options, :kind_of => Array, :default => nil

default_action :add

