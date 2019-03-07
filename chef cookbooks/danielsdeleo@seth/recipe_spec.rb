#
# Author:: Daniel DeLeo (<dan@getseth.com>)
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
require 'seth/dsl/recipe'


RecipeDSLExampleClass = Struct.new(:cookbook_name, :recipe_name)
class RecipeDSLExampleClass
  include Seth::DSL::Recipe
end

RecipeDSLBaseAPI = Struct.new(:cookbook_name, :recipe_name)
class RecipeDSLExampleSubclass < RecipeDSLBaseAPI
  include Seth::DSL::Recipe
end

# TODO: most of DSL::Recipe's implementation is tested in Seth::Recipe's tests,
# move those to here.
describe Seth::DSL::Recipe do

  let(:cookbook_name) { "example_cb" }
  let(:recipe_name) { "example_recipe" }

  shared_examples_for "A Recipe DSL Implementation" do

    it "responds to cookbook_name" do
      expect(recipe.cookbook_name).to eq(cookbook_name)
    end

    it "responds to recipe_name" do
      expect(recipe.recipe_name).to eq(recipe_name)
    end
  end

  context "when included in a class that defines the required interface directly" do

    let(:recipe) { RecipeDSLExampleClass.new(cookbook_name, recipe_name) }

    include_examples "A Recipe DSL Implementation"

  end

  # This is the situation that occurs when the Recipe DSL gets mixed in to a
  # resource, for example.
  context "when included in a class that defines the required interface in a superclass" do

    let(:recipe) { RecipeDSLExampleSubclass.new(cookbook_name, recipe_name) }

    include_examples "A Recipe DSL Implementation"

  end

end

