#
# Author:: John Keiser (<jkeiser@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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

require 'support/shared/integration/integration_helper'
require 'seth/ceth/serve'
require 'seth/server_api'

describe 'ceth serve' do
  extend IntegrationSupport
  include cethSupport
  include AppServerSupport

  when_the_repository 'also has one of each thing' do
    file 'nodes/x.json', { 'foo' => 'bar' }

    it 'ceth serve serves up /nodes/x' do
      exception = nil
      t = Thread.new do
        begin
          ceth('serve')
        rescue
          exception = $!
        end
      end
      begin
        Seth::Config.log_level = :debug
        Seth::Config.seth_server_url = 'http://localhost:8889'
        Seth::Config.node_name = nil
        Seth::Config.client_key = nil
        api = Seth::ServerAPI.new
        api.get('nodes/x')['name'].should == 'x'
      rescue
        if exception
          raise exception
        else
          raise
        end
      ensure
        t.kill
      end
    end
  end
end
