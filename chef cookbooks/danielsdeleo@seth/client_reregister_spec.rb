#
# Author:: Thomas Bishop (<bishop.thomas@gmail.com>)
# Copyright:: Copyright (c) 2011 Thomas Bishop
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

describe Seth::ceth::ClientReregister do
  before(:each) do
    @ceth = Seth::ceth::ClientReregister.new
    @ceth.name_args = [ 'adam' ]
    @client_mock = double('client_mock', :private_key => "foo_key")
    @stdout = StringIO.new
    @ceth.ui.stub(:stdout).and_return(@stdout)
  end

  context "when no client name is given on the command line" do
    before do
      @ceth.name_args = []
    end

    it 'should print usage and exit when a client name is not provided' do
      @ceth.should_receive(:show_usage)
      @ceth.ui.should_receive(:fatal)
      lambda { @ceth.run }.should raise_error(SystemExit)
    end
  end

  context 'when not configured for file output' do
    it 'reregisters the client and prints the key' do
      Seth::ApiClient.should_receive(:reregister).with('adam').and_return(@client_mock)
      @ceth.run
      @stdout.string.should match( /foo_key/ )
    end
  end

  context 'when configured for file output' do
    it 'should write the private key to a file' do
      Seth::ApiClient.should_receive(:reregister).with('adam').and_return(@client_mock)

      @ceth.config[:file] = '/tmp/monkeypants'
      filehandle = StringIO.new
      File.should_receive(:open).with('/tmp/monkeypants', 'w').and_yield(filehandle)
      @ceth.run
      filehandle.string.should == "foo_key"
    end
  end

end
