#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Author:: Juanje Ojeda (<juanje.ojeda@gmail.com>)
# Copyright:: Copyright (c) 2011-2012 Opscode, Inc.
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
require 'seth/ceth/core/object_loader'

describe Seth::ceth::Core::ObjectLoader do
  before(:each) do
    @ceth = Seth::ceth.new
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
    Dir.chdir(File.join(seth_SPEC_DATA, 'object_loader'))
  end

  shared_examples_for "Seth object" do |seth_class|
    it "should create a #{seth_class} object" do
      @object.should be_a_kind_of(seth_class)
    end

    it "should has a attribute 'name'" do
      @object.name.should eql('test')
    end
  end

  {
    'nodes' => Seth::Node,
    'roles' => Seth::Role,
    'environments' => Seth::Environment
  }.each do |repo_location, seth_class|

    describe "when the file is a #{seth_class}" do
      before do
        @loader = Seth::ceth::Core::ObjectLoader.new(seth_class, @ceth.ui)
      end

      describe "when the file is a Ruby" do
        before do
          @object = @loader.load_from(repo_location, 'test.rb')
        end

        it_behaves_like "Seth object", seth_class
      end

      #NOTE: This is check for the bug described at seth-2352
      describe "when the file is a JSON" do
        describe "and it has defined 'json_class'" do
          before do
            @object = @loader.load_from(repo_location, 'test_json_class.json')
          end

          it_behaves_like "Seth object", seth_class
        end

        describe "and it has not defined 'json_class'" do
          before do
            @object = @loader.load_from(repo_location, 'test.json')
          end

          it_behaves_like "Seth object", seth_class
        end
      end
    end
  end

end
