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

require 'seth/provider/batch'
require 'seth/provider/breakpoint'
require 'seth/provider/cookbook_file'
require 'seth/provider/cron'
require 'seth/provider/cron/solaris'
require 'seth/provider/cron/aix'
require 'seth/provider/deploy'
require 'seth/provider/directory'
require 'seth/provider/env'
require 'seth/provider/erl_call'
require 'seth/provider/execute'
require 'seth/provider/file'
require 'seth/provider/git'
require 'seth/provider/group'
require 'seth/provider/http_request'
require 'seth/provider/ifconfig'
require 'seth/provider/link'
require 'seth/provider/log'
require 'seth/provider/ohai'
require 'seth/provider/mdadm'
require 'seth/provider/mount'
require 'seth/provider/package'
require 'seth/provider/powershell_script'
require 'seth/provider/remote_directory'
require 'seth/provider/remote_file'
require 'seth/provider/route'
require 'seth/provider/ruby_block'
require 'seth/provider/script'
require 'seth/provider/service'
require 'seth/provider/subversion'
require 'seth/provider/template'
require 'seth/provider/user'
require 'seth/provider/whyrun_safe_ruby_block'

require 'seth/provider/env/windows'

require 'seth/provider/package/apt'
require 'seth/provider/package/dpkg'
require 'seth/provider/package/easy_install'
require 'seth/provider/package/freebsd/port'
require 'seth/provider/package/freebsd/pkg'
require 'seth/provider/package/freebsd/pkgng'
require 'seth/provider/package/ips'
require 'seth/provider/package/macports'
require 'seth/provider/package/pacman'
require 'seth/provider/package/portage'
require 'seth/provider/package/rpm'
require 'seth/provider/package/rubygems'
require 'seth/provider/package/yum'
require 'seth/provider/package/zypper'
require 'seth/provider/package/solaris'
require 'seth/provider/package/smartos'
require 'seth/provider/package/aix'

require 'seth/provider/service/arch'
require 'seth/provider/service/debian'
require 'seth/provider/service/freebsd'
require 'seth/provider/service/gentoo'
require 'seth/provider/service/init'
require 'seth/provider/service/insserv'
require 'seth/provider/service/invokercd'
require 'seth/provider/service/redhat'
require 'seth/provider/service/simple'
require 'seth/provider/service/systemd'
require 'seth/provider/service/upstart'
require 'seth/provider/service/windows'
require 'seth/provider/service/solaris'
require 'seth/provider/service/macosx'

require 'seth/provider/user/dscl'
require 'seth/provider/user/pw'
require 'seth/provider/user/useradd'
require 'seth/provider/user/windows'
require 'seth/provider/user/solaris'

require 'seth/provider/group/aix'
require 'seth/provider/group/dscl'
require 'seth/provider/group/gpasswd'
require 'seth/provider/group/groupadd'
require 'seth/provider/group/groupmod'
require 'seth/provider/group/pw'
require 'seth/provider/group/suse'
require 'seth/provider/group/usermod'
require 'seth/provider/group/windows'

require 'seth/provider/mount/mount'
require 'seth/provider/mount/aix'
require 'seth/provider/mount/solaris'
require 'seth/provider/mount/windows'

require 'seth/provider/deploy/revision'
require 'seth/provider/deploy/timestamped'

require 'seth/provider/remote_file/ftp'
require 'seth/provider/remote_file/http'
require 'seth/provider/remote_file/local_file'
require 'seth/provider/remote_file/fetcher'

require "seth/provider/lwrp_base"
require 'seth/provider/registry_key'

require 'seth/provider/file/content'
require 'seth/provider/remote_file/content'
require 'seth/provider/cookbook_file/content'
require 'seth/provider/template/content'

require 'seth/provider/ifconfig/redhat'
require 'seth/provider/ifconfig/debian'
require 'seth/provider/ifconfig/aix'
