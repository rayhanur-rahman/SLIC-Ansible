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
require 'seth/ceth/show'

describe 'ceth show' do
  extend IntegrationSupport
  include cethSupport

  include_context "default config options"

  when_the_seth_server "has one of each thing" do
    client 'x', '{}'
    cookbook 'x', '1.0.0', { 'metadata.rb' => 'version "1.0.0"' }
    data_bag 'x', { 'y' => '{}' }
    environment 'x', '{}'
    node 'x', '{}'
    role 'x', '{}'
    user 'x', '{}'

    when_the_repository 'also has one of each thing' do
      file 'clients/x.json', { 'foo' => 'bar' }
      file 'cookbooks/x/metadata.rb', 'version "1.0.1"'
      file 'data_bags/x/y.json', { 'foo' => 'bar' }
      file 'environments/_default.json', { 'foo' => 'bar' }
      file 'environments/x.json', { 'foo' => 'bar' }
      file 'nodes/x.json', { 'foo' => 'bar' }
      file 'roles/x.json', { 'foo' => 'bar' }
      file 'users/x.json', { 'foo' => 'bar' }

      it 'ceth show /cookbooks/x/metadata.rb shows the remote version' do
        ceth('show /cookbooks/x/metadata.rb').should_succeed <<EOM
/cookbooks/x/metadata.rb:
version "1.0.0"
EOM
      end
      it 'ceth show --local /cookbooks/x/metadata.rb shows the local version' do
        ceth('show --local /cookbooks/x/metadata.rb').should_succeed <<EOM
/cookbooks/x/metadata.rb:
version "1.0.1"
EOM
      end
      it 'ceth show /data_bags/x/y.json shows the remote version' do
        ceth('show /data_bags/x/y.json').should_succeed <<EOM
/data_bags/x/y.json:
{
  "id": "y"
}
EOM
      end
      it 'ceth show --local /data_bags/x/y.json shows the local version' do
        ceth('show --local /data_bags/x/y.json').should_succeed <<EOM
/data_bags/x/y.json:
{
  "foo": "bar"
}
EOM
      end
      it 'ceth show /environments/x.json shows the remote version', :pending => (RUBY_VERSION < "1.9") do
        ceth('show /environments/x.json').should_succeed <<EOM
/environments/x.json:
{
  "name": "x"
}
EOM
      end
      it 'ceth show --local /environments/x.json shows the local version' do
        ceth('show --local /environments/x.json').should_succeed <<EOM
/environments/x.json:
{
  "foo": "bar"
}
EOM
      end
      it 'ceth show /roles/x.json shows the remote version', :pending => (RUBY_VERSION < "1.9") do
        ceth('show /roles/x.json').should_succeed <<EOM
/roles/x.json:
{
  "name": "x"
}
EOM
      end
      it 'ceth show --local /roles/x.json shows the local version' do
        ceth('show --local /roles/x.json').should_succeed <<EOM
/roles/x.json:
{
  "foo": "bar"
}
EOM
      end
      # show directory
      it 'ceth show /data_bags/x fails' do
        ceth('show /data_bags/x').should_fail "ERROR: /data_bags/x: is a directory\n"
      end
      it 'ceth show --local /data_bags/x fails' do
        ceth('show --local /data_bags/x').should_fail "ERROR: /data_bags/x: is a directory\n"
      end
      # show nonexistent file
      it 'ceth show /environments/nonexistent.json fails' do
        ceth('show /environments/nonexistent.json').should_fail "ERROR: /environments/nonexistent.json: No such file or directory\n"
      end
      it 'ceth show --local /environments/nonexistent.json fails' do
        ceth('show --local /environments/nonexistent.json').should_fail "ERROR: /environments/nonexistent.json: No such file or directory\n"
      end
    end
  end

  when_the_seth_server 'has a hash with multiple keys' do
    environment 'x', {
      'default_attributes' => { 'foo' => 'bar' },
      'cookbook_versions' => { 'blah' => '= 1.0.0'},
      'override_attributes' => { 'x' => 'y' },
      'description' => 'woo',
      'name' => 'x'
    }
    it 'ceth show shows the attributes in a predetermined order', :pending => (RUBY_VERSION < "1.9") do
      ceth('show /environments/x.json').should_succeed <<EOM
/environments/x.json:
{
  "name": "x",
  "description": "woo",
  "cookbook_versions": {
    "blah": "= 1.0.0"
  },
  "default_attributes": {
    "foo": "bar"
  },
  "override_attributes": {
    "x": "y"
  }
}
EOM
    end
  end

  when_the_repository 'has an environment with bad JSON' do
    file 'environments/x.json', '{'
    it 'ceth show succeeds' do
      ceth('show --local /environments/x.json').should_succeed <<EOM
/environments/x.json:
{
EOM
    end
  end
end
