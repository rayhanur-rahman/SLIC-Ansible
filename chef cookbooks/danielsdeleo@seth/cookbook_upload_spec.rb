#
# Author:: Matthew Kent (<mkent@magoazul.com>)
# Author:: Steven Danna (<steve@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

require 'seth/cookbook_uploader'
require 'timeout'

describe Seth::ceth::CookbookUpload do
  let(:cookbook) { Seth::CookbookVersion.new('test_cookbook', '/tmp/blah.txt') }

  let(:cookbooks_by_name) do
    {cookbook.name => cookbook}
  end

  let(:cookbook_loader) do
    cookbook_loader = cookbooks_by_name.dup
    cookbook_loader.stub(:merged_cookbooks).and_return([])
    cookbook_loader.stub(:load_cookbooks).and_return(cookbook_loader)
    cookbook_loader
  end

  let(:cookbook_uploader) { double(:upload_cookbooks => nil) }

  let(:output) { StringIO.new }

  let(:name_args) { ['test_cookbook'] }

  let(:ceth) do
    k = Seth::ceth::CookbookUpload.new
    k.name_args = name_args
    k.ui.stub(:stdout).and_return(output)
    k.ui.stub(:stderr).and_return(output)
    k
  end

  before(:each) do
    Seth::CookbookLoader.stub(:new).and_return(cookbook_loader)
  end

  describe 'with --concurrency' do
    it 'should upload cookbooks with predefined concurrency' do
      Seth::CookbookVersion.stub(:list_all_versions).and_return({})
      ceth.config[:concurrency] = 3
      test_cookbook = Seth::CookbookVersion.new('test_cookbook', '/tmp/blah')
      cookbook_loader.stub(:each).and_yield("test_cookbook", test_cookbook)
      cookbook_loader.stub(:cookbook_names).and_return(["test_cookbook"])
      Seth::CookbookUploader.should_receive(:new).with( kind_of(Array),  kind_of(Array),
        {:force=>nil, :concurrency => 3}).and_return(double("Seth::CookbookUploader", :upload_cookbooks=> true))
      ceth.run
    end
  end

  describe 'run' do
    before(:each) do
      Seth::CookbookUploader.stub(:new => cookbook_uploader)
      Seth::CookbookVersion.stub(:list_all_versions).and_return({})
    end

    it 'should print usage and exit when a cookbook name is not provided' do
      ceth.name_args = []
      ceth.should_receive(:show_usage)
      ceth.ui.should_receive(:fatal)
      lambda { ceth.run }.should raise_error(SystemExit)
    end

    describe 'when specifying a cookbook name' do
      it 'should upload the cookbook' do
        ceth.should_receive(:upload).once
        ceth.run
      end

      it 'should report on success' do
        ceth.should_receive(:upload).once
        ceth.ui.should_receive(:info).with(/Uploaded 1 cookbook/)
        ceth.run
      end
    end

    describe 'when specifying the same cookbook name twice' do
      it 'should upload the cookbook only once' do
        ceth.name_args = ['test_cookbook', 'test_cookbook']
        ceth.should_receive(:upload).once
        ceth.run
      end
    end

    context "when uploading a cookbook that uses deprecated overlays" do

      before do
        cookbook_loader.stub(:merged_cookbooks).and_return(['test_cookbook'])
        cookbook_loader.stub(:merged_cookbook_paths).
          and_return({'test_cookbook' => %w{/path/one/test_cookbook /path/two/test_cookbook}})
      end

      it "emits a warning" do
        ceth.run
        expected_message=<<-E
WARNING: The cookbooks: test_cookbook exist in multiple places in your cookbook_path.
A composite version of these cookbooks has been compiled for uploading.

IMPORTANT: In a future version of Seth, this behavior will be removed and you will no longer
be able to have the same version of a cookbook in multiple places in your cookbook_path.
WARNING: The affected cookbooks are located:
test_cookbook:
  /path/one/test_cookbook
  /path/two/test_cookbook
E
        output.string.should include(expected_message)
      end
    end

    describe 'when specifying a cookbook name among many' do
      let(:name_args) { ['test_cookbook1'] }

      let(:cookbooks_by_name) do
        {
          'test_cookbook1' => Seth::CookbookVersion.new('test_cookbook1', '/tmp/blah'),
          'test_cookbook2' => Seth::CookbookVersion.new('test_cookbook2', '/tmp/blah'),
          'test_cookbook3' => Seth::CookbookVersion.new('test_cookbook3', '/tmp/blah')
        }
      end

      it "should read only one cookbook" do
        cookbook_loader.should_receive(:[]).once.with('test_cookbook1').and_call_original
        ceth.run
      end

      it "should not read all cookbooks" do
        cookbook_loader.should_not_receive(:load_cookbooks)
        ceth.run
      end

      it "should upload only one cookbook" do
        ceth.should_receive(:upload).exactly(1).times
        ceth.run
      end
    end

    # This is testing too much.  We should break it up.
    describe 'when specifying a cookbook name with dependencies' do
      let(:name_args) { ["test_cookbook2"] }

      let(:cookbooks_by_name) do
        { "test_cookbook1" => test_cookbook1,
          "test_cookbook2" => test_cookbook2,
          "test_cookbook3" => test_cookbook3 }
      end

      let(:test_cookbook1) { Seth::CookbookVersion.new('test_cookbook1', '/tmp/blah') }

      let(:test_cookbook2) do
        c = Seth::CookbookVersion.new('test_cookbook2')
        c.metadata.depends("test_cookbook3")
        c
      end

      let(:test_cookbook3) do
        c = Seth::CookbookVersion.new('test_cookbook3')
        c.metadata.depends("test_cookbook1")
        c.metadata.depends("test_cookbook2")
        c
      end

      it "should upload all dependencies once" do
        ceth.config[:depends] = true
        ceth.stub(:cookbook_names).and_return(["test_cookbook1", "test_cookbook2", "test_cookbook3"])
        ceth.should_receive(:upload).exactly(3).times
        lambda do
          Timeout::timeout(5) do
            ceth.run
          end
        end.should_not raise_error
      end
    end

    describe 'when specifying a cookbook name with missing dependencies' do
      let(:cookbook_dependency) { Seth::CookbookVersion.new('dependency', '/tmp/blah') }

      before(:each) do
        cookbook.metadata.depends("dependency")
        cookbook_loader.stub(:[])  do |ckbk|
          { "test_cookbook" =>  cookbook,
            "dependency" => cookbook_dependency}[ckbk]
        end
        ceth.stub(:cookbook_names).and_return(["cookbook_dependency", "test_cookbook"])
        @stdout, @stderr, @stdin = StringIO.new, StringIO.new, StringIO.new
        ceth.ui = Seth::ceth::UI.new(@stdout, @stderr, @stdin, {})
      end

      it 'should exit and not upload the cookbook' do
        cookbook_loader.should_receive(:[]).once.with('test_cookbook')
        cookbook_loader.should_not_receive(:load_cookbooks)
        cookbook_uploader.should_not_receive(:upload_cookbooks)
        expect {ceth.run}.to raise_error(SystemExit)
      end

      it 'should output a message for a single missing dependency' do
        expect {ceth.run}.to raise_error(SystemExit)
        @stderr.string.should include('Cookbook test_cookbook depends on cookbooks which are not currently')
        @stderr.string.should include('being uploaded and cannot be found on the server.')
        @stderr.string.should include("The missing cookbook(s) are: 'dependency' version '>= 0.0.0'")
      end

      it 'should output a message for a multiple missing dependencies which are concatenated' do
        cookbook_dependency2 = Seth::CookbookVersion.new('dependency2')
        cookbook.metadata.depends("dependency2")
        cookbook_loader.stub(:[])  do |ckbk|
          { "test_cookbook" =>  cookbook,
            "dependency" => cookbook_dependency,
            "dependency2" => cookbook_dependency2}[ckbk]
        end
        ceth.stub(:cookbook_names).and_return(["dependency", "dependency2", "test_cookbook"])
        expect {ceth.run}.to raise_error(SystemExit)
        @stderr.string.should include('Cookbook test_cookbook depends on cookbooks which are not currently')
        @stderr.string.should include('being uploaded and cannot be found on the server.')
        @stderr.string.should include("The missing cookbook(s) are:")
        @stderr.string.should include("'dependency' version '>= 0.0.0'")
        @stderr.string.should include("'dependency2' version '>= 0.0.0'")
      end
    end

    it "should freeze the version of the cookbooks if --freeze is specified" do
      ceth.config[:freeze] = true
      cookbook.should_receive(:freeze_version).once
      ceth.run
    end

    describe 'with -a or --all' do
      before(:each) do
        ceth.config[:all] = true
        @test_cookbook1 = Seth::CookbookVersion.new('test_cookbook1', '/tmp/blah')
        @test_cookbook2 = Seth::CookbookVersion.new('test_cookbook2', '/tmp/blah')
        cookbook_loader.stub(:each).and_yield("test_cookbook1", @test_cookbook1).and_yield("test_cookbook2", @test_cookbook2)
        cookbook_loader.stub(:cookbook_names).and_return(["test_cookbook1", "test_cookbook2"])
      end

      it 'should upload all cookbooks' do
        ceth.should_receive(:upload).once
        ceth.run
      end

      it 'should report on success' do
        ceth.should_receive(:upload).once
        ceth.ui.should_receive(:info).with(/Uploaded all cookbooks/)
        ceth.run
      end

      it 'should update the version constraints for an environment' do
        ceth.stub(:assert_environment_valid!).and_return(true)
        ceth.config[:environment] = "production"
        ceth.should_receive(:update_version_constraints).once
        ceth.run
      end
    end

    describe 'when a frozen cookbook exists on the server' do
      it 'should fail to replace it' do
        exception = Seth::Exceptions::CookbookFrozen.new
        cookbook_uploader.should_receive(:upload_cookbooks).
          and_raise(exception)
        ceth.ui.stub(:error)
        ceth.ui.should_receive(:error).with(exception)
        lambda { ceth.run }.should raise_error(SystemExit)
      end

      it 'should not update the version constraints for an environment' do
        ceth.stub(:assert_environment_valid!).and_return(true)
        ceth.config[:environment] = "production"
        ceth.stub(:upload).and_raise(Seth::Exceptions::CookbookFrozen)
        ceth.ui.should_receive(:error).with(/Failed to upload 1 cookbook/)
        ceth.ui.should_receive(:warn).with(/Not updating version constraints/)
        ceth.should_not_receive(:update_version_constraints)
        lambda { ceth.run }.should raise_error(SystemExit)
      end
    end
  end # run
end
