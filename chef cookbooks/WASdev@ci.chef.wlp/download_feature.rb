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
Downloads an asset from the Liberty Repository or a local [LARS](https://github.com/WASdev/tool.lars) repository.

@action download Downloads an asset from the configured repository to the specified directory.

@section Examples
```ruby
wlp_download_feature "mongodb" do
  name "mongodb-2.0"
  directory "/opt/ibm/wlp/features"
  accept_license true
end
```
#>
=end

actions :download


#<> @attribute name Specifies the name of the asset to be downloaded.
attribute :name, :kind_of => String, :default => nil

#<> @attribute directory Specifies which local directory path utilities are downloaded to when using the :download action.
attribute :directory, :kind_of => String, :default => nil

#<> @attribute accept_license Specifies whether to accept the license terms and conditions of the feature.
attribute :accept_license, :kind_of => [TrueClass, FalseClass], :default => false

default_action :download
