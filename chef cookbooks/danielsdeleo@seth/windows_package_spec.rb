#
# Author:: Bryan McLellan <btm@loftninjas.org>
# Copyright:: Copyright (c) 2014 Seth Software, Inc.
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

describe Seth::Resource::WindowsPackage, "initialize", :windows_only do

  let(:resource) { Seth::Resource::WindowsPackage.new("solitaire.msi") }

  it "returns a Seth::Resource::WindowsPackage" do
    expect(resource).to be_a_kind_of(Seth::Resource::WindowsPackage)
  end

  it "sets the resource_name to :windows_package" do
    expect(resource.resource_name).to eql(:windows_package)
  end

  it "sets the provider to Seth::Provider::Package::Windows" do
    expect(resource.provider).to eql(Seth::Provider::Package::Windows)
  end

  it "supports setting installer_type" do
    resource.installer_type("msi")
    expect(resource.installer_type).to eql("msi")
  end

  # String, Integer
  [ "600", 600 ].each do |val|
    it "supports setting a timeout as a #{val.class}" do
      resource.timeout(val)
      expect(resource.timeout).to eql(val)
    end
  end

  # String, Integer, Array
  [ "42", 42, [47, 48, 49] ].each do |val|
    it "supports setting an alternate return value as a #{val.class}" do
      resource.returns(val)
      expect(resource.returns).to eql(val)
    end
  end

  it "coverts a source to an absolute path" do
    ::File.stub(:absolute_path).and_return("c:\\Files\\frost.msi")
    resource.source("frost.msi")
    expect(resource.source).to eql "c:\\Files\\frost.msi"
  end

  it "converts slashes to backslashes in the source path" do
    ::File.stub(:absolute_path).and_return("c:\\frost.msi")
    resource.source("c:/frost.msi")
    expect(resource.source).to eql "c:\\frost.msi"
  end

  it "defaults source to the resource name" do
    # it's a little late to stub out File.absolute_path
    expect(resource.source).to include("solitaire.msi")
  end
end
