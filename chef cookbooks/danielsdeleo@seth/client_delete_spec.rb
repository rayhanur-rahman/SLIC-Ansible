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

describe Seth::ceth::ClientDelete do
  before(:each) do
    @ceth = Seth::ceth::ClientDelete.new
    # defaults
    @ceth.config = {
      :delete_validators => false
    }
    @ceth.name_args = [ 'adam' ]
  end

  describe 'run' do
    it 'should delete the client' do
      @ceth.should_receive(:delete_object).with(Seth::ApiClient, 'adam', 'client')
      @ceth.run
    end

    it 'should print usage and exit when a client name is not provided' do
      @ceth.name_args = []
      @ceth.should_receive(:show_usage)
      @ceth.ui.should_receive(:fatal)
      lambda { @ceth.run }.should raise_error(SystemExit)
    end
  end

  describe 'with a validator' do
    before(:each) do
      Seth::ceth::UI.stub(:confirm).and_return(true)
      @ceth.stub(:confirm).and_return(true)
      @client = Seth::ApiClient.new
      Seth::ApiClient.should_receive(:load).and_return(@client)
    end

    it 'should delete non-validator client if --force is not set' do
      @ceth.config[:delete_validators] = false
      @client.should_receive(:destroy).and_return(@client)
      @ceth.should_receive(:msg)

      @ceth.run
    end

    it 'should delete non-validator client if --force is set' do
      @ceth.config[:delete_validators] = true
      @client.should_receive(:destroy).and_return(@client)
      @ceth.should_receive(:msg)

      @ceth.run
    end

    it 'should not delete validator client if --force is not set' do
      @client.validator(true)
      @ceth.ui.should_receive(:fatal)
      lambda { @ceth.run}.should raise_error(SystemExit)
    end

    it 'should delete validator client if --force is set' do
      @ceth.config[:delete_validators] = true
      @client.should_receive(:destroy).and_return(@client)
      @ceth.should_receive(:msg)

      @ceth.run
    end
  end
end
