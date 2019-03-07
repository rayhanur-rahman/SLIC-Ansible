#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

require 'seth/resource/apt_package'
require 'seth/resource/bash'
require 'seth/resource/batch'
require 'seth/resource/breakpoint'
require 'seth/resource/cookbook_file'
require 'seth/resource/seth_gem'
require 'seth/resource/cron'
require 'seth/resource/csh'
require 'seth/resource/deploy'
require 'seth/resource/deploy_revision'
require 'seth/resource/directory'
require 'seth/resource/dpkg_package'
require 'seth/resource/easy_install_package'
require 'seth/resource/env'
require 'seth/resource/erl_call'
require 'seth/resource/execute'
require 'seth/resource/file'
require 'seth/resource/freebsd_package'
require 'seth/resource/ips_package'
require 'seth/resource/gem_package'
require 'seth/resource/git'
require 'seth/resource/group'
require 'seth/resource/http_request'
require 'seth/resource/ifconfig'
require 'seth/resource/link'
require 'seth/resource/log'
require 'seth/resource/macports_package'
require 'seth/resource/mdadm'
require 'seth/resource/mount'
require 'seth/resource/ohai'
require 'seth/resource/package'
require 'seth/resource/pacman_package'
require 'seth/resource/perl'
require 'seth/resource/portage_package'
require 'seth/resource/powershell_script'
require 'seth/resource/python'
require 'seth/resource/registry_key'
require 'seth/resource/remote_directory'
require 'seth/resource/remote_file'
require 'seth/resource/rpm_package'
require 'seth/resource/solaris_package'
require 'seth/resource/route'
require 'seth/resource/ruby'
require 'seth/resource/ruby_block'
require 'seth/resource/scm'
require 'seth/resource/script'
require 'seth/resource/service'
require 'seth/resource/subversion'
require 'seth/resource/smartos_package'
require 'seth/resource/template'
require 'seth/resource/timestamped_deploy'
require 'seth/resource/user'
require 'seth/resource/whyrun_safe_ruby_block'
require 'seth/resource/windows_package'
require 'seth/resource/yum_package'
require 'seth/resource/lwrp_base'
require 'seth/resource/bff_package'
