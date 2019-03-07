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

require 'spec_helper'

describe "ceth smoke tests" do

  # Since our specs load all code, there could be a case where ceth does not
  # run correctly b/c of a missing require, but is not caught by other tests.
  #
  # We run `ceth -v` to verify that ceth at least loads all its code.
  it "can run and print its version" do
    ceth_path = File.expand_path("../../bin/ceth", seth_SPEC_DATA)
    ceth_cmd = Mixlib::ShellOut.new("#{ceth_path} -v")
    ceth_cmd.run_command
    ceth_cmd.error!
    ceth_cmd.stdout.should include(Seth::VERSION)
  end
end
