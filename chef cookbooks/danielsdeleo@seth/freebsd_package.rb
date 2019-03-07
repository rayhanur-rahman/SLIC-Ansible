#
# Authors:: AJ Christensen (<aj@opscode.com>)
#           Richard Manyanza (<liseki@nyikacraftsmen.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# Copyright:: Copyright (c) 2014 Richard Manyanza.
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
require 'seth/provider/package/freebsd/port'
require 'seth/provider/package/freebsd/pkg'
require 'seth/provider/package/freebsd/pkgng'
require 'seth/mixin/shell_out'

class Seth
  class Resource
    class FreebsdPackage < Seth::Resource::Package
      include Seth::Mixin::ShellOut

      provides :package, :on_platforms => ["freebsd"]


      def initialize(name, run_context=nil)
        super
        @resource_name = :freebsd_package
      end

      def after_created
        assign_provider
      end



      private

      def assign_provider
        @provider = if @source.to_s =~ /^ports$/i
                      Seth::Provider::Package::Freebsd::Port
                    elsif ships_with_pkgng? || supports_pkgng?
                      Seth::Provider::Package::Freebsd::Pkgng
                    else
                      Seth::Provider::Package::Freebsd::Pkg
                    end
      end

      def ships_with_pkgng?
        # It was not until __FreeBSD_version 1000017 that pkgng became
        # the default binary package manager. See '/usr/ports/Mk/bsd.port.mk'.
        node[:os_version].to_i >= 1000017
      end

      def supports_pkgng?
        !!shell_out!("make -V WITH_PKGNG", :env => nil).stdout.match(/yes/i)
      end

    end
  end
end

