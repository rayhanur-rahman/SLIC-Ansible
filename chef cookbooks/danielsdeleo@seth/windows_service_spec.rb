#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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
require 'spec_helper'
if Seth::Platform.windows?
  require 'seth/application/windows_service'
end

describe "Seth::Application::WindowsService", :windows_only do
  let (:instance) {Seth::Application::WindowsService.new}
  let (:shell_out_result) {Object.new}
  let (:tempfile) {Tempfile.new "log_file"}
  before do
    instance.stub(:parse_options)
    shell_out_result.stub(:stdout)
    shell_out_result.stub(:stderr)
  end
  it "runs seth-client in new process" do
    instance.should_receive(:configure_seth).twice
    instance.service_init
    instance.should_receive(:run_seth_client).and_call_original
    instance.should_receive(:shell_out).and_return(shell_out_result)
    instance.stub(:running?).and_return(true, false)
    instance.instance_variable_get(:@service_signal).stub(:wait)
    instance.stub(:state).and_return(4)
    instance.service_main
  end
  it "passes config params to new process" do
    Seth::Config.merge!({:log_location => tempfile.path, :config_file => "test_config_file", :log_level => :info})
    instance.should_receive(:configure_seth).twice
    instance.service_init
    instance.stub(:running?).and_return(true, false)
    instance.instance_variable_get(:@service_signal).stub(:wait)
    instance.stub(:state).and_return(4)
    instance.should_receive(:run_seth_client).and_call_original
    instance.should_receive(:shell_out).with("seth-client  --no-fork -c test_config_file -L #{tempfile.path}").and_return(shell_out_result)
    instance.service_main
    tempfile.unlink
  end
end
