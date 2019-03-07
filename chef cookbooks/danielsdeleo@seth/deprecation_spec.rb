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
require 'seth/mixin/deprecation'

describe Seth::Mixin do
  describe "deprecating constants (Class/Module)" do
    before do
      Seth::Mixin.deprecate_constant(:DeprecatedClass, seth::Node, "This is a test deprecation")
      @log_io = StringIO.new
      Seth::Log.init(@log_io)
    end

    it "has a list of deprecated constants" do
      Seth::Mixin.deprecated_constants.should have_key(:DeprecatedClass)
    end

    it "returns the replacement when accessing the deprecated constant" do
      Seth::Mixin::DeprecatedClass.should == seth::Node
    end

    it "warns when accessing the deprecated constant" do
      Seth::Mixin::DeprecatedClass
      @log_io.string.should include("This is a test deprecation")
    end
  end
end

describe Seth::Mixin::Deprecation::DeprecatedInstanceVariable do
  before do
    Seth::Log.logger = Logger.new(StringIO.new)

    @deprecated_ivar = Seth::Mixin::Deprecation::DeprecatedInstanceVariable.new('value', 'an_ivar')
  end

  it "forward method calls to the target object" do
    @deprecated_ivar.length.should == 5
    @deprecated_ivar.to_sym.should == :value
  end

end
