#
# Author:: Bryan McLellan <btm@loftninjas.org>
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

require 'seth/resource/package'
require 'seth/resource/gem_package'

class Seth
  class Resource
    class SethGem < seth::Resource::Package::GemPackage

      provides :seth_gem, :on_platforms => :all

      def initialize(name, run_context=nil)
        super
        @resource_name = :seth_gem
        @gem_binary = RbConfig::CONFIG['bindir'] + "/gem"
        @provider = Seth::Provider::Package::Rubygems
      end

      # The seth_gem resources is for installing gems to the current gem environment only for use by Seth cookbooks.
      def gem_binary(arg=nil)
        if arg
          raise ArgumentError, "The seth_gem resource is restricted to the current gem environment, use gem_package to install to other environments."
        end

        @gem_binary
      end

      def after_created
        # Seth::Resource.run_action: Caveat: this skips seth::Runner.run_action, where notifications are handled
        # Action could be an array of symbols, but probably won't (think install + enable for a package)
        Array(@action).each do |action|
          self.run_action(action)
        end
        Gem.clear_paths
      end
    end
  end
end
