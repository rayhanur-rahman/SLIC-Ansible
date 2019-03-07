#
# Cookbook Name:: bcpc
# Resource:: zbx_autoreg
#
# Copyright 2016, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


actions :create
default_action :create

# Name of the action
attribute :name, :name_attribute => true, :kind_of => String, :required => true
# Zabbix metadata
attribute :metadata, :kind_of => String, :default => lazy { |x| x.name }
# Zabbix template
attribute :template, :kind_of => [String, Array], :default => lazy { |x| x.name }
# Zabbix hostgroup
attribute :hostgroup, :kind_of => [String, Array], :default => lazy { |x| x.name }
