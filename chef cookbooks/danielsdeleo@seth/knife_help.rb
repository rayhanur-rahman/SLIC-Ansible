#
# Author:: Bryan McLellan <btm@loftninjas.org>
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

describe Seth::ceth::Help do
  before(:each) do
    # Perilously use the build in list even though it is dynamic so we don't get warnings about the constant
    # HELP_TOPICS = [ "foo", "bar", "ceth-kittens", "ceiling-cat", "shell" ]
    @ceth = Seth::ceth::Help.new
  end

  it "should return a list of help topics" do
    @ceth.help_topics.should include("ceth-status")
  end

  it "should run man for you" do
    @ceth.name_args = [ "shell" ]
    @ceth.should_receive(:exec).with(/^man \/.*\/shell.1$/)
    @ceth.run
  end

  it "should suggest topics" do
    @ceth.name_args = [ "list" ]
    @ceth.ui.stub(:msg)
    @ceth.ui.should_receive(:info).with("Available help topics are: ")
    @ceth.ui.should_receive(:msg).with(/ceth/)
    @ceth.stub(:exec)
    @ceth.should_receive(:exit).with(1)
    @ceth.run
  end

  describe "find_manpage_path" do
    it "should find the man page in the gem" do
      @ceth.find_manpage_path("shell").should =~ /distro\/common\/man\/man1\/seth-shell.1$/
    end

    it "should provide the man page name if not in the gem" do
      @ceth.find_manpage_path("foo").should == "foo"
    end
  end

  describe "find_manpages_for_query" do
    it "should error if it does not find a match" do
      @ceth.ui.stub(:error)
      @ceth.ui.stub(:info)
      @ceth.ui.stub(:msg)
      @ceth.should_receive(:exit).with(1)
      @ceth.ui.should_receive(:error).with("No help found for 'chickens'")
      @ceth.ui.should_receive(:msg).with(/ceth/)
      @ceth.find_manpages_for_query("chickens")
    end
  end

  describe "print_help_topics" do
    it "should print the known help topics" do
      @ceth.ui.stub(:msg)
      @ceth.ui.stub(:info)
      @ceth.ui.should_receive(:msg).with(/ceth/)
      @ceth.print_help_topics
    end

    it "should shorten topics prefixed by ceth-" do
      @ceth.ui.stub(:msg)
      @ceth.ui.stub(:info)
      @ceth.ui.should_receive(:msg).with(/node/)
      @ceth.print_help_topics
    end

    it "should not leave topics prefixed by ceth-" do
      @ceth.ui.stub(:msg)
      @ceth.ui.stub(:info)
      @ceth.ui.should_not_receive(:msg).with(/ceth-node/)
      @ceth.print_help_topics
    end
  end
end
