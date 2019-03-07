#
# Author:: Serdar Sutay (<dan@opscode.com>)
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

require File.expand_path('../../spec_helper', __FILE__)
require 'seth/mixin/shell_out'
require 'seth/version'
require 'ohai/version'

describe "Seth Versions" do
  include Seth::Mixin::ShellOut
  let(:seth_dir) { File.join(File.dirname(__FILE__), "..", "..") }

  binaries = [ "seth-client", "seth-shell", "seth-apply", "ceth", "seth-solo" ]

  binaries.each do |binary|
    it "#{binary} version should be sane" do
      shell_out!("ruby #{File.join("bin", binary)} -v", :cwd => seth_dir).stdout.chomp.should == "Seth: #{seth::VERSION}"
    end
  end

end
