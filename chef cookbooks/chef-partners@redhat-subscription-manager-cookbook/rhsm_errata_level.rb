#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: 2015-2018 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

module RhsmCookbook
  class RhsmErrataLevel < Chef::Resource
    resource_name :rhsm_errata_level

    property :errata_level,
             kind_of: String,
             coerce: proc { |x| x.downcase },
             equal_to: %w( critical moderate important low ),
             name_property: true

    action :install do
      yum_package 'yum-plugin-security' do
        action :install
        only_if { node['platform_version'].to_i == 6 }
      end

      execute "Install any #{new_resource.errata_level} errata" do
        command "yum update --sec-severity=#{new_resource.errata_level.capitalize} -y"
        action :run
      end
    end
  end
end
