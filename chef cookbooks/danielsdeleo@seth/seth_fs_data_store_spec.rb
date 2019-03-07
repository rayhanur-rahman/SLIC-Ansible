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
require 'seth/ceth/list'
require 'seth/ceth/delete'
require 'seth/ceth/show'
require 'seth/ceth/raw'
require 'seth/ceth/cookbook_upload'

describe 'SethFSDataStore tests' do
  extend IntegrationSupport
  include cethSupport

  when_the_repository "has one of each thing" do
    file 'clients/x.json', {}
    file 'cookbooks/x/metadata.rb', 'version "1.0.0"'
    file 'data_bags/x/y.json', {}
    file 'environments/x.json', {}
    file 'nodes/x.json', {}
    file 'roles/x.json', {}
    file 'users/x.json', {}

    context 'GET /TYPE' do
      it 'ceth list -z -R returns everything' do
        ceth('list -z -Rfp /').should_succeed <<EOM
/clients/
/clients/x.json
/cookbooks/
/cookbooks/x/
/cookbooks/x/metadata.rb
/data_bags/
/data_bags/x/
/data_bags/x/y.json
/environments/
/environments/x.json
/nodes/
/nodes/x.json
/roles/
/roles/x.json
/users/
/users/x.json
EOM
      end
    end

    context 'DELETE /TYPE/NAME' do
      it 'ceth delete -z /clients/x.json works' do
        ceth('delete -z /clients/x.json').should_succeed "Deleted /clients/x.json\n"
        ceth('list -z -Rfp /clients').should_succeed ''
      end

      it 'ceth delete -z -r /cookbooks/x works' do
        ceth('delete -z -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -z -Rfp /cookbooks').should_succeed ''
      end

      it 'ceth delete -z -r /data_bags/x works' do
        ceth('delete -z -r /data_bags/x').should_succeed "Deleted /data_bags/x\n"
        ceth('list -z -Rfp /data_bags').should_succeed ''
      end

      it 'ceth delete -z /data_bags/x/y.json works' do
        ceth('delete -z /data_bags/x/y.json').should_succeed "Deleted /data_bags/x/y.json\n"
        ceth('list -z -Rfp /data_bags').should_succeed "/data_bags/x/\n"
      end

      it 'ceth delete -z /environments/x.json works' do
        ceth('delete -z /environments/x.json').should_succeed "Deleted /environments/x.json\n"
        ceth('list -z -Rfp /environments').should_succeed ''
      end

      it 'ceth delete -z /nodes/x.json works' do
        ceth('delete -z /nodes/x.json').should_succeed "Deleted /nodes/x.json\n"
        ceth('list -z -Rfp /nodes').should_succeed ''
      end

      it 'ceth delete -z /roles/x.json works' do
        ceth('delete -z /roles/x.json').should_succeed "Deleted /roles/x.json\n"
        ceth('list -z -Rfp /roles').should_succeed ''
      end

      it 'ceth delete -z /users/x.json works' do
        ceth('delete -z /users/x.json').should_succeed "Deleted /users/x.json\n"
        ceth('list -z -Rfp /users').should_succeed ''
      end
    end

    context 'GET /TYPE/NAME' do
      it 'ceth show -z /clients/x.json works' do
        ceth('show -z /clients/x.json').should_succeed /"x"/
      end

      it 'ceth show -z /cookbooks/x/metadata.rb works' do
        ceth('show -z /cookbooks/x/metadata.rb').should_succeed "/cookbooks/x/metadata.rb:\nversion \"1.0.0\"\n"
      end

      it 'ceth show -z /data_bags/x/y.json works' do
        ceth('show -z /data_bags/x/y.json').should_succeed /"y"/
      end

      it 'ceth show -z /environments/x.json works' do
        ceth('show -z /environments/x.json').should_succeed /"x"/
      end

      it 'ceth show -z /nodes/x.json works' do
        ceth('show -z /nodes/x.json').should_succeed /"x"/
      end

      it 'ceth show -z /roles/x.json works' do
        ceth('show -z /roles/x.json').should_succeed /"x"/
      end

      it 'ceth show -z /users/x.json works' do
        ceth('show -z /users/x.json').should_succeed /"x"/
      end
    end

    context 'PUT /TYPE/NAME' do
      file 'empty.json', {}
      file 'rolestuff.json', '{"description":"hi there","name":"x"}'
      file 'cookbooks_to_upload/x/metadata.rb', "version '1.0.0'\n\n"

      it 'ceth raw -z -i empty.json -m PUT /clients/x' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /clients/x").should_succeed /"x"/
        ceth('list --local /clients').should_succeed "/clients/x.json\n"
      end

      it 'ceth cookbook upload works' do
        ceth("cookbook upload -z --cookbook-path #{path_to('cookbooks_to_upload')} x").should_succeed <<EOM
Uploading x              [1.0.0]
Uploaded 1 cookbook.
EOM
        ceth('list --local -Rfp /cookbooks').should_succeed "/cookbooks/x/\n/cookbooks/x/metadata.rb\n"
      end

      it 'ceth raw -z -i empty.json -m PUT /data/x/y' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /data/x/y").should_succeed /"y"/
        ceth('list --local -Rfp /data_bags').should_succeed "/data_bags/x/\n/data_bags/x/y.json\n"
      end

      it 'ceth raw -z -i empty.json -m PUT /environments/x' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /environments/x").should_succeed /"x"/
        ceth('list --local /environments').should_succeed "/environments/x.json\n"
      end

      it 'ceth raw -z -i empty.json -m PUT /nodes/x' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /nodes/x").should_succeed /"x"/
        ceth('list --local /nodes').should_succeed "/nodes/x.json\n"
      end

      it 'ceth raw -z -i empty.json -m PUT /roles/x' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /roles/x").should_succeed /"x"/
        ceth('list --local /roles').should_succeed "/roles/x.json\n"
      end

      it 'ceth raw -z -i empty.json -m PUT /users/x' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /users/x").should_succeed /"x"/
        ceth('list --local /users').should_succeed "/users/x.json\n"
      end

      it 'After ceth raw -z -i rolestuff.json -m PUT /roles/x, the output is pretty', :pending => (RUBY_VERSION < "1.9") do
        ceth("raw -z -i #{path_to('rolestuff.json')} -m PUT /roles/x").should_succeed /"x"/
        IO.read(path_to('roles/x.json')).should == <<EOM.strip
{
  "name": "x",
  "description": "hi there"
}
EOM
      end
    end
  end

  when_the_repository 'is empty' do
    context 'POST /TYPE/NAME' do
      file 'empty.json', { 'name' => 'z' }
      file 'empty_x.json', { 'name' => 'x' }
      file 'empty_id.json', { 'id' => 'z' }
      file 'rolestuff.json', '{"description":"hi there","name":"x"}'
      file 'cookbooks_to_upload/z/metadata.rb', "version '1.0.0'"

      it 'ceth raw -z -i empty.json -m POST /clients' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /clients").should_succeed /uri/
        ceth('list --local /clients').should_succeed "/clients/z.json\n"
      end

      it 'ceth cookbook upload works' do
        ceth("cookbook upload -z --cookbook-path #{path_to('cookbooks_to_upload')} z").should_succeed <<EOM
Uploading z            [1.0.0]
Uploaded 1 cookbook.
EOM
        ceth('list --local -Rfp /cookbooks').should_succeed "/cookbooks/z/\n/cookbooks/z/metadata.rb\n"
      end

      it 'ceth raw -z -i empty.json -m POST /data' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /data").should_succeed /uri/
        ceth('list --local -Rfp /data_bags').should_succeed "/data_bags/z/\n"
      end

      it 'ceth raw -z -i empty.json -m POST /data/x' do
        ceth("raw -z -i #{path_to('empty_x.json')} -m POST /data").should_succeed /uri/
        ceth("raw -z -i #{path_to('empty_id.json')} -m POST /data/x").should_succeed /"z"/
        ceth('list --local -Rfp /data_bags').should_succeed "/data_bags/x/\n/data_bags/x/z.json\n"
      end

      it 'ceth raw -z -i empty.json -m POST /environments' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /environments").should_succeed /uri/
        ceth('list --local /environments').should_succeed "/environments/z.json\n"
      end

      it 'ceth raw -z -i empty.json -m POST /nodes' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /nodes").should_succeed /uri/
        ceth('list --local /nodes').should_succeed "/nodes/z.json\n"
      end

      it 'ceth raw -z -i empty.json -m POST /roles' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /roles").should_succeed /uri/
        ceth('list --local /roles').should_succeed "/roles/z.json\n"
      end

      it 'ceth raw -z -i empty.json -m POST /users' do
        ceth("raw -z -i #{path_to('empty.json')} -m POST /users").should_succeed /uri/
        ceth('list --local /users').should_succeed "/users/z.json\n"
      end

      it 'After ceth raw -z -i rolestuff.json -m POST /roles, the output is pretty', :pending => (RUBY_VERSION < "1.9") do
        ceth("raw -z -i #{path_to('rolestuff.json')} -m POST /roles").should_succeed /uri/
        IO.read(path_to('roles/x.json')).should == <<EOM.strip
{
  "name": "x",
  "description": "hi there"
}
EOM
      end
    end

    it 'ceth list -z -R returns nothing' do
      ceth('list -z -Rfp /').should_succeed <<EOM
/clients/
/cookbooks/
/data_bags/
/environments/
/nodes/
/roles/
/users/
EOM
    end

    context 'DELETE /TYPE/NAME' do
      it 'ceth delete -z /clients/x.json fails with an error' do
        ceth('delete -z /clients/x.json').should_fail "ERROR: /clients/x.json: No such file or directory\n"
      end

      it 'ceth delete -z -r /cookbooks/x fails with an error' do
        ceth('delete -z -r /cookbooks/x').should_fail "ERROR: /cookbooks/x: No such file or directory\n"
      end

      it 'ceth delete -z -r /data_bags/x fails with an error' do
        ceth('delete -z -r /data_bags/x').should_fail "ERROR: /data_bags/x: No such file or directory\n"
      end

      it 'ceth delete -z /data_bags/x/y.json fails with an error' do
        ceth('delete -z /data_bags/x/y.json').should_fail "ERROR: /data_bags/x/y.json: No such file or directory\n"
      end

      it 'ceth delete -z /environments/x.json fails with an error' do
        ceth('delete -z /environments/x.json').should_fail "ERROR: /environments/x.json: No such file or directory\n"
      end

      it 'ceth delete -z /nodes/x.json fails with an error' do
        ceth('delete -z /nodes/x.json').should_fail "ERROR: /nodes/x.json: No such file or directory\n"
      end

      it 'ceth delete -z /roles/x.json fails with an error' do
        ceth('delete -z /roles/x.json').should_fail "ERROR: /roles/x.json: No such file or directory\n"
      end

      it 'ceth delete -z /users/x.json fails with an error' do
        ceth('delete -z /users/x.json').should_fail "ERROR: /users/x.json: No such file or directory\n"
      end
    end

    context 'GET /TYPE/NAME' do
      it 'ceth show -z /clients/x.json fails with an error' do
        ceth('show -z /clients/x.json').should_fail "ERROR: /clients/x.json: No such file or directory\n"
      end

      it 'ceth show -z /cookbooks/x/metadata.rb fails with an error' do
        ceth('show -z /cookbooks/x/metadata.rb').should_fail "ERROR: /cookbooks/x/metadata.rb: No such file or directory\n"
      end

      it 'ceth show -z /data_bags/x/y.json fails with an error' do
        ceth('show -z /data_bags/x/y.json').should_fail "ERROR: /data_bags/x/y.json: No such file or directory\n"
      end

      it 'ceth show -z /environments/x.json fails with an error' do
        ceth('show -z /environments/x.json').should_fail "ERROR: /environments/x.json: No such file or directory\n"
      end

      it 'ceth show -z /nodes/x.json fails with an error' do
        ceth('show -z /nodes/x.json').should_fail "ERROR: /nodes/x.json: No such file or directory\n"
      end

      it 'ceth show -z /roles/x.json fails with an error' do
        ceth('show -z /roles/x.json').should_fail "ERROR: /roles/x.json: No such file or directory\n"
      end

      it 'ceth show -z /users/x.json fails with an error' do
        ceth('show -z /users/x.json').should_fail "ERROR: /users/x.json: No such file or directory\n"
      end
    end

    context 'PUT /TYPE/NAME' do
      file 'empty.json', {}

      it 'ceth raw -z -i empty.json -m PUT /clients/x fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /clients/x").should_fail /404/
      end

      it 'ceth raw -z -i empty.json -m PUT /data/x/y fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /data/x/y").should_fail /404/
      end

      it 'ceth raw -z -i empty.json -m PUT /environments/x fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /environments/x").should_fail /404/
      end

      it 'ceth raw -z -i empty.json -m PUT /nodes/x fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /nodes/x").should_fail /404/
      end

      it 'ceth raw -z -i empty.json -m PUT /roles/x fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /roles/x").should_fail /404/
      end

      it 'ceth raw -z -i empty.json -m PUT /users/x fails with 404' do
        ceth("raw -z -i #{path_to('empty.json')} -m PUT /users/x").should_fail /404/
      end
    end
  end
end
