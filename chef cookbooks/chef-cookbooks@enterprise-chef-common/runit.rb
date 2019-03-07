#
# Copyright:: 2013-2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

project_name = node['enterprise']['name']
node.default_unless[node['enterprise']['name']] = {} # ~FC047 (See https://github.com/acrmp/foodcritic/issues/225)
install_path = node[project_name]['install_path']

node.override['runit']['sv_bin']       = "#{install_path}/embedded/bin/sv"
node.override['runit']['svlogd_bin']   = "#{install_path}/embedded/bin/svlogd"
node.override['runit']['chpst_bin']    = "#{install_path}/embedded/bin/chpst"
node.override['runit']['service_dir']  = "#{install_path}/service"
node.override['runit']['sv_dir']       = "#{install_path}/sv"
node.override['runit']['lsb_init_dir'] = "#{install_path}/init"

component_runit_supervisor node['enterprise']['name'] do
  ctl_name node[node['enterprise']['name']]['ctl_name'] ||
           "#{node['enterprise']['name']}-ctl"
  sysvinit_id node[node['enterprise']['name']]['sysvinit_id']
  install_path node[node['enterprise']['name']]['install_path']
end
