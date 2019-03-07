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

require 'shellwords'

module RhsmCookbook
  module RhsmHelpers
    def register_command
      command = %w(subscription-manager register)

      if new_resource.activation_key
        unless new_resource.activation_key.empty?
          raise 'Unable to register - you must specify organization when using activation keys' if new_resource.organization.nil?

          command << new_resource.activation_key.map { |key| "--activationkey=#{Shellwords.shellescape(key)}" }
          command << "--org=#{Shellwords.shellescape(new_resource.organization)}"
          command << '--force' if new_resource.force

          return command.join(' ')
        end
      end

      if new_resource.username && new_resource.password
        raise 'Unable to register - you must specify environment when using username/password' if new_resource.environment.nil? && using_satellite_host?

        command << "--username=#{Shellwords.shellescape(new_resource.username)}"
        command << "--password=#{Shellwords.shellescape(new_resource.password)}"
        command << "--environment=#{Shellwords.shellescape(new_resource.environment)}" if using_satellite_host?
        command << '--auto-attach' if new_resource.auto_attach
        command << '--force' if new_resource.force

        return command.join(' ')
      end

      raise 'Unable to create register command - you must specify activation_key or username/password'
    end

    def using_satellite_host?
      !new_resource.satellite_host.nil?
    end

    def registered_with_rhsm?
      cmd = Mixlib::ShellOut.new('subscription-manager status', env: { LANG: node['rhsm']['lang'] })
      cmd.run_command
      !cmd.stdout.match(/Overall Status: Unknown/)
    end

    def katello_cert_rpm_installed?
      cmd = Mixlib::ShellOut.new('rpm -qa | grep katello-ca-consumer')
      cmd.run_command
      !cmd.stdout.match(/katello-ca-consumer/).nil?
    end

    def subscription_attached?(subscription)
      cmd = Mixlib::ShellOut.new("subscription-manager list --consumed | grep #{subscription}", env: { LANG: node['rhsm']['lang'] })
      cmd.run_command
      !cmd.stdout.match(/Pool ID:\s+#{subscription}$/).nil?
    end

    def repo_enabled?(repo)
      cmd = Mixlib::ShellOut.new('subscription-manager repos --list-enabled', env: { LANG: node['rhsm']['lang'] })
      cmd.run_command
      !cmd.stdout.match(/Repo ID:\s+#{repo}$/).nil?
    end

    def serials_by_pool
      serials = {}
      pool = nil
      serial = nil

      cmd = Mixlib::ShellOut.new('subscription-manager list --consumed', env: { LANG: node['rhsm']['lang'] })
      cmd.run_command
      cmd.stdout.lines.each do |line|
        line.strip!
        key, value = line.split(/:\s+/, 2)
        next unless ['Pool ID', 'Serial'].include?(key)

        if key == 'Pool ID'
          pool = value
        elsif key == 'Serial'
          serial = value
        end

        next unless pool && serial

        serials[pool] = serial
        pool = nil
        serial = nil
      end

      serials
    end

    def pool_serial(pool_id)
      serials_by_pool[pool_id]
    end
  end
end
