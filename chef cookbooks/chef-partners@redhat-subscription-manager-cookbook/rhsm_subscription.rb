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
  class RhsmSubscription < Chef::Resource
    resource_name :rhsm_subscription

    property :pool_id, String, name_property: true

    action :attach do
      execute "Attach subscription pool #{new_resource.pool_id}" do
        command "subscription-manager attach --pool=#{new_resource.pool_id}"
        action :run
        not_if { subscription_attached?(new_resource.pool_id) }
      end
    end

    action :remove do
      execute "Remove subscription pool #{new_resource.pool_id}" do
        command "subscription-manager remove --serial=#{pool_serial(new_resource.pool_id)}"
        action :run
        only_if { subscription_attached?(new_resource.pool_id) }
      end
    end

    action_class do
      include RhsmCookbook::RhsmHelpers
    end
  end
end
