#
# Author:: Steven Danna
# Copyright:: Copyright (c) 2012 Opscode, Inc
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

describe Seth::ceth::UserList do
  before(:each) do
    Seth::ceth::UserList.load_deps
    @ceth = Seth::ceth::UserList.new
  end

  it 'lists the users' do
    Seth::User.should_receive(:list)
    @ceth.should_receive(:format_list_for_display)
    @ceth.run
  end
end
