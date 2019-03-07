# frozen_string_literal: true
# Cookbook :: ambari_metrics
# Recipe :: ambari_metrics_configure_ams_components
# Copyright 2018, Bloomberg Finance L.P.
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
template '/etc/hbase/conf/hadoop-metrics2-hbase.properties' do
  source 'hadoop-metrics2-hbase.properties.erb'
  mode '0755'
  only_if { Chef::File.directory?('/etc/hbase/conf') }
end

template '/etc/hadoop/conf/hadoop-metrics2.properties' do
  source 'hadoop-metrics2.properties.erb'
  mode '0755'
  only_if { Chef::File.directory?('/etc/hadoop/conf') }
end
