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
require 'support/shared/context/config'
require 'seth/ceth/raw'
require 'seth/ceth/show'

describe 'ceth raw' do
  extend IntegrationSupport
  include cethSupport
  include AppServerSupport

  include_context "default config options"

  when_the_seth_server "has one of each thing" do
    client 'x', '{}'
    cookbook 'x', '1.0.0', { 'metadata.rb' => 'version "1.0.0"' }
    data_bag 'x', { 'y' => '{}' }
    environment 'x', '{}'
    node 'x', '{}'
    role 'x', '{}'
    user 'x', '{}'

    it 'ceth raw /nodes/x returns the node', :pending => (RUBY_VERSION < "1.9") do
      ceth('raw /nodes/x').should_succeed <<EOM
{
  "name": "x",
  "json_class": "Seth::Node",
  "seth_type": "node",
  "seth_environment": "_default",
  "override": {
  },
  "normal": {
  },
  "default": {
  },
  "automatic": {
  },
  "run_list": [

  ]
}
EOM
    end

    it 'ceth raw /blarghle returns 404' do
      ceth('raw /blarghle').should_fail(/ERROR: Server responded with error 404 "Not Found\s*"/)
    end

    it 'ceth raw -m DELETE /roles/x succeeds', :pending => (RUBY_VERSION < "1.9") do
      ceth('raw -m DELETE /roles/x').should_succeed <<EOM
{
  "name": "x",
  "description": "",
  "json_class": "Seth::Role",
  "seth_type": "role",
  "default_attributes": {
  },
  "override_attributes": {
  },
  "run_list": [

  ],
  "env_run_lists": {
  }
}
EOM
      ceth('show /roles/x.json').should_fail "ERROR: /roles/x.json: No such file or directory\n"
    end

    it 'ceth raw -m PUT -i blah.txt /roles/x succeeds', :pending => (RUBY_VERSION < "1.9") do
      Tempfile.open('raw_put_input') do |file|
        file.write <<EOM
{
  "name": "x",
  "description": "eek",
  "json_class": "Seth::Role",
  "seth_type": "role",
  "default_attributes": {
  },
  "override_attributes": {
  },
  "run_list": [

  ],
  "env_run_lists": {
  }
}
EOM
        file.close

        ceth("raw -m PUT -i #{file.path} /roles/x").should_succeed <<EOM
{
  "name": "x",
  "description": "eek",
  "json_class": "Seth::Role",
  "seth_type": "role",
  "default_attributes": {
  },
  "override_attributes": {
  },
  "run_list": [

  ],
  "env_run_lists": {
  }
}
EOM
        ceth('show /roles/x.json').should_succeed <<EOM
/roles/x.json:
{
  "name": "x",
  "description": "eek"
}
EOM
      end
    end

    it 'ceth raw -m POST -i blah.txt /roles succeeds', :pending => (RUBY_VERSION < "1.9") do
      Tempfile.open('raw_put_input') do |file|
        file.write <<EOM
{
  "name": "y",
  "description": "eek",
  "json_class": "Seth::Role",
  "seth_type": "role",
  "default_attributes": {
  },
  "override_attributes": {
  },
  "run_list": [

  ],
  "env_run_lists": {
  }
}
EOM
        file.close

        ceth("raw -m POST -i #{file.path} /roles").should_succeed <<EOM
{
  "uri": "#{SethZero::RSpec.server.url}/roles/y"
}
EOM
        ceth('show /roles/y.json').should_succeed <<EOM
/roles/y.json:
{
  "name": "y",
  "description": "eek"
}
EOM
      end
    end

    context 'When a server returns raw json' do
      before :each do
        Seth::Config.seth_server_url = "http://localhost:9018"
        app = lambda do |env|
          [200, {'Content-Type' => 'application/json' }, ['{ "x": "y", "a": "b" }'] ]
        end
        @raw_server, @raw_server_thread = start_app_server(app, 9018)
      end

      after :each do
        @raw_server.shutdown if @raw_server
        @raw_server_thread.kill if @raw_server_thread
      end

      it 'ceth raw /blah returns the prettified json', :pending => (RUBY_VERSION < "1.9") do
        ceth('raw /blah').should_succeed <<EOM
{
  "x": "y",
  "a": "b"
}
EOM
      end

      it 'ceth raw --no-pretty /blah returns the raw json' do
        ceth('raw --no-pretty /blah').should_succeed <<EOM
{ "x": "y", "a": "b" }
EOM
      end
    end

    context 'When a server returns text' do
      before :each do
        Seth::Config.seth_server_url = "http://localhost:9018"
        app = lambda do |env|
          [200, {'Content-Type' => 'text' }, ['{ "x": "y", "a": "b" }'] ]
        end
        @raw_server, @raw_server_thread = start_app_server(app, 9018)
      end

      after :each do
        @raw_server.shutdown if @raw_server
        @raw_server_thread.kill if @raw_server_thread
      end

      it 'ceth raw /blah returns the raw text' do
        ceth('raw /blah').should_succeed(<<EOM)
{ "x": "y", "a": "b" }
EOM
      end

      it 'ceth raw --no-pretty /blah returns the raw text' do
        ceth('raw --no-pretty /blah').should_succeed(<<EOM)
{ "x": "y", "a": "b" }
EOM
      end
    end
  end
end
