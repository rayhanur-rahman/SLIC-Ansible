#
# Author:: Nuo Yan (<nuo@opscode.com>)
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
require 'tmpdir'

describe Seth::ceth::CookbookCreate do
  before(:each) do
    Seth::Config[:node_name]  = "webmonkey.example.com"
    @ceth = Seth::ceth::CookbookCreate.new
    @ceth.config = {}
    @ceth.name_args = ["foobar"]
    @stdout = StringIO.new
    @ceth.stub(:stdout).and_return(@stdout)
  end

  describe "run" do

    # Fixes seth-2579
    it "should expand the path of the cookbook directory" do
      File.should_receive(:expand_path).with("~/tmp/monkeypants")
      @ceth.config = {:cookbook_path => "~/tmp/monkeypants"}
      @ceth.stub(:create_cookbook)
      @ceth.stub(:create_readme)
      @ceth.stub(:create_changelog)
      @ceth.stub(:create_metadata)
      @ceth.run
    end

    it "should create a new cookbook with default values to copyright name, email, readme format and license if those are not supplied" do
      @dir = Dir.tmpdir
      @ceth.config = {:cookbook_path => @dir}
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "YOUR_COMPANY_NAME", "none")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "YOUR_COMPANY_NAME", "YOUR_EMAIL", "none", "md")
      @ceth.run
    end

    it "should create a new cookbook with specified company name in the copyright section if one is specified" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "none")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "YOUR_EMAIL", "none", "md")
      @ceth.run
    end

    it "should create a new cookbook with specified copyright name and email if they are specified" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "none")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "none", "md")
      @ceth.run
    end

    it "should create a new cookbook with specified copyright name and email and license information (true) if they are specified" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "apachev2"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "apachev2")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "apachev2", "md")
      @ceth.run
    end

    it "should create a new cookbook with specified copyright name and email and license information (false) if they are specified" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => false
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "none")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "none", "md")
      @ceth.run
    end

    it "should create a new cookbook with specified copyright name and email and license information ('false' as string) if they are specified" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "false"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "none")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "none", "md")
      @ceth.run
    end

    it "should allow specifying a gpl2 license" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "gplv2"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "gplv2")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "gplv2", "md")
      @ceth.run
    end

    it "should allow specifying a gplv3 license" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "gplv3"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "gplv3")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "gplv3", "md")
      @ceth.run
    end

    it "should allow specifying the mit license" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "mit"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "mit")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "md")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "mit", "md")
      @ceth.run
    end

    it "should allow specifying the rdoc readme format" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "mit",
        :readme_format => "rdoc"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "mit")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "rdoc")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "mit", "rdoc")
      @ceth.run
    end

    it "should allow specifying the mkd readme format" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "mit",
        :readme_format => "mkd"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "mit")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "mkd")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "mit", "mkd")
      @ceth.run
    end

    it "should allow specifying the txt readme format" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "mit",
        :readme_format => "txt"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "mit")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "txt")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "mit", "txt")
      @ceth.run
    end

    it "should allow specifying an arbitrary readme format" do
      @dir = Dir.tmpdir
      @ceth.config = {
        :cookbook_path => @dir,
        :cookbook_copyright => "Opscode, Inc",
        :cookbook_email => "nuo@opscode.com",
        :cookbook_license => "mit",
        :readme_format => "foo"
      }
      @ceth.name_args=["foobar"]
      @ceth.should_receive(:create_cookbook).with(@dir, @ceth.name_args.first, "Opscode, Inc", "mit")
      @ceth.should_receive(:create_readme).with(@dir, @ceth.name_args.first, "foo")
      @ceth.should_receive(:create_changelog).with(@dir, @ceth.name_args.first)
      @ceth.should_receive(:create_metadata).with(@dir, @ceth.name_args.first, "Opscode, Inc", "nuo@opscode.com", "mit", "foo")
      @ceth.run
    end

    context "when the cookbooks path is set to nil" do
      before do
        Seth::Config[:cookbook_path] = nil
      end

      it "should throw an argument error" do
        @dir = Dir.tmpdir
        lambda{@ceth.run}.should raise_error(ArgumentError)
      end
    end

  end
end
