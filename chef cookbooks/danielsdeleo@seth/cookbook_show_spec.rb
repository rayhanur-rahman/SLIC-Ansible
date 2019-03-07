#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, eersion 2.0
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

# rename to cookbook not coookbook
require 'spec_helper'

describe Seth::ceth::CookbookShow do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::CookbookShow.new
    @ceth.config = { }
    @ceth.name_args = [ "cookbook_name" ]
    @rest = double(Seth::REST)
    @ceth.stub(:rest).and_return(@rest)
    @ceth.stub(:pretty_print).and_return(true)
    @ceth.stub(:output).and_return(true)
  end

  describe "run" do
    describe "with 0 arguments: help" do
      it 'should should print usage and exit when given no arguments' do
        @ceth.name_args = []
        @ceth.should_receive(:show_usage)
        @ceth.ui.should_receive(:fatal)
        lambda { @ceth.run }.should raise_error(SystemExit)
      end
    end

    describe "with 1 argument: versions" do
      before(:each) do
        @response = {
          "cookbook_name" => {
            "url" => "http://url/cookbooks/cookbook_name",
            "versions" => [
              { "version" => "0.10.0", "url" => "http://url/cookbooks/cookbook_name/0.10.0" },
              { "version" => "0.9.0", "url" => "http://url/cookbookx/cookbook_name/0.9.0" },
              { "version" => "0.8.0", "url" => "http://url/cookbooks/cookbook_name/0.8.0" }
            ]
          }
        }
      end

      it "should show the raw cookbook data" do
        @rest.should_receive(:get_rest).with("cookbooks/cookbook_name").and_return(@response)
        @ceth.should_receive(:format_cookbook_list_for_display).with(@response)
        @ceth.run
      end

      it "should respect the user-supplied environment" do
        @ceth.config[:environment] = "foo"
        @rest.should_receive(:get_rest).with("environments/foo/cookbooks/cookbook_name").and_return(@response)
        @ceth.should_receive(:format_cookbook_list_for_display).with(@response)
        @ceth.run
      end
    end

    describe "with 2 arguments: name and version" do
      before(:each) do
        @ceth.name_args << "0.1.0"
        @response = { "0.1.0" => { "recipes" => {"default.rb" => ""} } }
      end

      it "should show the specific part of a cookbook" do
        @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@response)
        @ceth.should_receive(:output).with(@response)
        @ceth.run
      end
    end

    describe "with 3 arguments: name, version, and segment" do
      before(:each) do
        @ceth.name_args = [ "cookbook_name", "0.1.0", "recipes" ]
        @cookbook_response = Seth::CookbookVersion.new("cookbook_name")
        @manifest = {
          "recipes" => [
            {
              :name => "default.rb",
              :path => "recipes/default.rb",
              :checksum => "1234",
              :url => "http://example.org/files/default.rb"
            }
          ]
        }
        @cookbook_response.manifest = @manifest
        @response = {"name"=>"default.rb", "url"=>"http://example.org/files/default.rb", "checksum"=>"1234", "path"=>"recipes/default.rb"}
      end

      it "should print the json of the part" do
        @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
        @ceth.should_receive(:output).with(@cookbook_response.manifest["recipes"])
        @ceth.run
      end
    end

    describe "with 4 arguments: name, version, segment and filename" do
      before(:each) do
        @ceth.name_args = [ "cookbook_name", "0.1.0", "recipes", "default.rb" ]
        @cookbook_response = Seth::CookbookVersion.new("cookbook_name")
        @cookbook_response.manifest = {
          "recipes" => [
            {
              :name => "default.rb",
              :path => "recipes/default.rb",
              :checksum => "1234",
              :url => "http://example.org/files/default.rb"
            }
          ]
        }
        @response = "Example recipe text"
      end

      it "should print the raw result of the request (likely a file!)" do
        @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
        @rest.should_receive(:get_rest).with("http://example.org/files/default.rb", true).and_return(StringIO.new(@response))
        @ceth.should_receive(:pretty_print).with(@response)
        @ceth.run
      end
    end

    describe "with 4 arguments: name, version, segment and filename -- with specificity" do
      before(:each) do
        @ceth.name_args = [ "cookbook_name", "0.1.0", "files", "afile.rb" ]
        @cookbook_response = Seth::CookbookVersion.new("cookbook_name")
        @cookbook_response.manifest = {
          "files" => [
            {
              :name => "afile.rb",
              :path => "files/host-examplehost.example.org/afile.rb",
              :checksum => "1111",
              :specificity => "host-examplehost.example.org",
              :url => "http://example.org/files/1111"
            },
            {
              :name => "afile.rb",
              :path => "files/ubuntu-9.10/afile.rb",
              :checksum => "2222",
              :specificity => "ubuntu-9.10",
              :url => "http://example.org/files/2222"
            },
            {
              :name => "afile.rb",
              :path => "files/ubuntu/afile.rb",
              :checksum => "3333",
              :specificity => "ubuntu",
              :url => "http://example.org/files/3333"
            },
            {
              :name => "afile.rb",
              :path => "files/default/afile.rb",
              :checksum => "4444",
              :specificity => "default",
              :url => "http://example.org/files/4444"
            },
          ]
        }

        @response = "Example recipe text"
      end

      describe "with --fqdn" do
        it "should pass the fqdn" do
          @ceth.config[:platform] = "example_platform"
          @ceth.config[:platform_version] = "1.0"
          @ceth.config[:fqdn] = "examplehost.example.org"
          @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
          @rest.should_receive(:get_rest).with("http://example.org/files/1111", true).and_return(StringIO.new(@response))
          @ceth.should_receive(:pretty_print).with(@response)
          @ceth.run
        end
      end

      describe "and --platform" do
        it "should pass the platform" do
          @ceth.config[:platform] = "ubuntu"
          @ceth.config[:platform_version] = "1.0"
          @ceth.config[:fqdn] = "differenthost.example.org"
          @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
          @rest.should_receive(:get_rest).with("http://example.org/files/3333", true).and_return(StringIO.new(@response))
          @ceth.should_receive(:pretty_print).with(@response)
          @ceth.run
        end
      end

      describe "and --platform-version" do
        it "should pass the platform" do
          @ceth.config[:platform] = "ubuntu"
          @ceth.config[:platform_version] = "9.10"
          @ceth.config[:fqdn] = "differenthost.example.org"
          @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
          @rest.should_receive(:get_rest).with("http://example.org/files/2222", true).and_return(StringIO.new(@response))
          @ceth.should_receive(:pretty_print).with(@response)
          @ceth.run
        end
      end

      describe "with none of the arguments, it should use the default" do
        it "should pass them all" do
          @rest.should_receive(:get_rest).with("cookbooks/cookbook_name/0.1.0").and_return(@cookbook_response)
          @rest.should_receive(:get_rest).with("http://example.org/files/4444", true).and_return(StringIO.new(@response))
          @ceth.should_receive(:pretty_print).with(@response)
          @ceth.run
        end
      end

    end
  end
end

