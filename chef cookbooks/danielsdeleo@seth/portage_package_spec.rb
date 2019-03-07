#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Seth::Resource::PortagePackage, "initialize" do

  before(:each) do
    @resource = Seth::Resource::PortagePackage.new("foo")
  end

  it "should return a Seth::Resource::PortagePackage" do
    @resource.should be_a_kind_of(Seth::Resource::PortagePackage)
  end

  it "should set the resource_name to :portage_package" do
    @resource.resource_name.should eql(:portage_package)
  end

  it "should set the provider to Seth::Provider::Package::Portage" do
    @resource.provider.should eql(Seth::Provider::Package::Portage)
  end
end
