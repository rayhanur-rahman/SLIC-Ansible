#
# Author:: Phil Dibowitz (<phild@fb.com>)
# Copyright:: Copyright (c) 2013 Facebook
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

describe Seth::Provider::WhyrunSafeRubyBlock, "initialize" do
  before(:each) do
    $evil_global_evil_laugh = :wahwah
    @node = Seth::Node.new
    @events = Seth::EventDispatch::Dispatcher.new
    @run_context = Seth::RunContext.new(@node, {}, @events)
    @new_resource = Seth::Resource::WhyrunSafeRubyBlock.new("bloc party")
    @new_resource.block { $evil_global_evil_laugh = :mwahahaha}
    @provider = Seth::Provider::WhyrunSafeRubyBlock.new(@new_resource, @run_context)
  end

  it "should call the block and flag the resource as updated" do
    @provider.run_action(:create)
    $evil_global_evil_laugh.should == :mwahahaha
    @new_resource.should be_updated
  end

  it "should call the block and flat the resource as updated - even in whyrun" do
    Seth::Config[:why_run] = true
    @provider.run_action(:create)
    $evil_global_evil_laugh.should == :mwahahaha
    @new_resource.should be_updated
    Seth::Config[:why_run] = false
  end

end

