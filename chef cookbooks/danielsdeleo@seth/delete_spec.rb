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
require 'seth/ceth/delete'
require 'seth/ceth/list'
require 'seth/ceth/raw'

describe 'ceth delete' do
  extend IntegrationSupport
  include cethSupport

  let :everything do
    <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
  end

  let :server_everything do
    <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
  end
  let :server_nothing do
    <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/cookbooks
/data_bags
/environments
/environments/_default.json
/nodes
/roles
/users
/users/admin.json
EOM
  end

  let :nothing do
    <<EOM
/clients
/cookbooks
/data_bags
/environments
/nodes
/roles
/users
EOM
  end

  when_the_seth_server "has one of each thing" do
    client 'x', '{}'
    cookbook 'x', '1.0.0', { 'metadata.rb' => 'version "1.0.0"' }
    data_bag 'x', { 'y' => '{}' }
    environment 'x', '{}'
    node 'x', '{}'
    role 'x', '{}'
    user 'x', '{}'

    when_the_repository 'also has one of each thing' do
      file 'clients/x.json', {}
      file 'cookbooks/x/metadata.rb', ''
      file 'data_bags/x/y.json', {}
      file 'environments/_default.json', {}
      file 'environments/x.json', {}
      file 'nodes/x.json', {}
      file 'roles/x.json', {}
      file 'users/x.json', {}

      it 'ceth delete --both /cookbooks/x fails' do
        ceth('delete --both /cookbooks/x').should_fail <<EOM
ERROR: /cookbooks/x (remote) must be deleted recursively!  Pass -r to ceth delete.
ERROR: /cookbooks/x (local) must be deleted recursively!  Pass -r to ceth delete.
EOM
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /cookbooks/x deletes x' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete -r --local /cookbooks/x deletes x locally but not remotely' do
        ceth('delete -r --local /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete -r /cookbooks/x deletes x remotely but not locally' do
        ceth('delete -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed everything
      end

      # TODO delete empty data bag (particularly different on local side)
      context 'with an empty data bag on both' do
        data_bag 'empty', {}
        directory 'data_bags/empty'
        it 'ceth delete --both /data_bags/empty fails but deletes local version' do
          ceth('delete --both /data_bags/empty').should_fail <<EOM
ERROR: /data_bags/empty (remote) must be deleted recursively!  Pass -r to ceth delete.
ERROR: /data_bags/empty (local) must be deleted recursively!  Pass -r to ceth delete.
EOM
          ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/empty
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
          ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/empty
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
        end
      end

      it 'ceth delete --both /data_bags/x fails' do
        ceth('delete --both /data_bags/x').should_fail <<EOM
ERROR: /data_bags/x (remote) must be deleted recursively!  Pass -r to ceth delete.
ERROR: /data_bags/x (local) must be deleted recursively!  Pass -r to ceth delete.
EOM
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /data_bags/x deletes x' do
        ceth('delete --both -r /data_bags/x').should_succeed "Deleted /data_bags/x\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /environments/x.json deletes x' do
        ceth('delete --both /environments/x.json').should_succeed "Deleted /environments/x.json\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /roles/x.json deletes x' do
        ceth('delete --both /roles/x.json').should_succeed "Deleted /roles/x.json\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /environments/_default.json fails but still deletes the local copy' do
        ceth('delete --both /environments/_default.json').should_fail :stderr => "ERROR: /environments/_default.json (remote) cannot be deleted (default environment cannot be modified).\n", :stdout => "Deleted /environments/_default.json\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /environments/nonexistent.json fails' do
        ceth('delete --both /environments/nonexistent.json').should_fail "ERROR: /environments/nonexistent.json: No such file or directory\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both / fails' do
        ceth('delete --both /').should_fail <<EOM
ERROR: / (remote) cannot be deleted.
ERROR: / (local) cannot be deleted.
EOM
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /* fails' do
        ceth('delete --both -r /*').should_fail <<EOM
ERROR: / (remote) cannot be deleted.
ERROR: / (local) cannot be deleted.
ERROR: /clients (remote) cannot be deleted.
ERROR: /clients (local) cannot be deleted.
ERROR: /cookbooks (remote) cannot be deleted.
ERROR: /cookbooks (local) cannot be deleted.
ERROR: /data_bags (remote) cannot be deleted.
ERROR: /data_bags (local) cannot be deleted.
ERROR: /environments (remote) cannot be deleted.
ERROR: /environments (local) cannot be deleted.
ERROR: /nodes (remote) cannot be deleted.
ERROR: /nodes (local) cannot be deleted.
ERROR: /roles (remote) cannot be deleted.
ERROR: /roles (local) cannot be deleted.
ERROR: /users (remote) cannot be deleted.
ERROR: /users (local) cannot be deleted.
EOM
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed everything
      end
    end

    when_the_repository 'has only top-level directories' do
      directory 'clients'
      directory 'cookbooks'
      directory 'data_bags'
      directory 'environments'
      directory 'nodes'
      directory 'roles'
      directory 'users'

      it 'ceth delete --both /cookbooks/x fails' do
        ceth('delete --both /cookbooks/x').should_fail "ERROR: /cookbooks/x (remote) must be deleted recursively!  Pass -r to ceth delete.\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both -r /cookbooks/x deletes x' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both /data_bags/x fails' do
        ceth('delete --both /data_bags/x').should_fail "ERROR: /data_bags/x (remote) must be deleted recursively!  Pass -r to ceth delete.\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both -r /data_bags/x deletes x' do
        ceth('delete --both -r /data_bags/x').should_succeed "Deleted /data_bags/x\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both /environments/x.json deletes x' do
        ceth('delete --both /environments/x.json').should_succeed "Deleted /environments/x.json\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both /roles/x.json deletes x' do
        ceth('delete --both /roles/x.json').should_succeed "Deleted /roles/x.json\n"
        ceth('list -Rf /').should_succeed <<EOM
/clients
/clients/seth-validator.json
/clients/seth-webui.json
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/users
/users/admin.json
/users/x.json
EOM
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both /environments/_default.json fails' do
        ceth('delete --both /environments/_default.json').should_fail "", :stderr => "ERROR: /environments/_default.json (remote) cannot be deleted (default environment cannot be modified).\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both / fails' do
        ceth('delete --both /').should_fail "ERROR: / (remote) cannot be deleted.\nERROR: / (local) cannot be deleted.\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both -r /* fails' do
        ceth('delete --both -r /*').should_fail <<EOM
ERROR: / (remote) cannot be deleted.
ERROR: / (local) cannot be deleted.
ERROR: /clients (remote) cannot be deleted.
ERROR: /clients (local) cannot be deleted.
ERROR: /cookbooks (remote) cannot be deleted.
ERROR: /cookbooks (local) cannot be deleted.
ERROR: /data_bags (remote) cannot be deleted.
ERROR: /data_bags (local) cannot be deleted.
ERROR: /environments (remote) cannot be deleted.
ERROR: /environments (local) cannot be deleted.
ERROR: /nodes (remote) cannot be deleted.
ERROR: /nodes (local) cannot be deleted.
ERROR: /roles (remote) cannot be deleted.
ERROR: /roles (local) cannot be deleted.
ERROR: /users (remote) cannot be deleted.
ERROR: /users (local) cannot be deleted.
EOM
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      it 'ceth delete --both /environments/nonexistent.json fails' do
        ceth('delete --both /environments/nonexistent.json').should_fail "ERROR: /environments/nonexistent.json: No such file or directory\n"
        ceth('list -Rf /').should_succeed server_everything
        ceth('list -Rf --local /').should_succeed nothing
      end

      context 'and cwd is at the top level' do
        cwd '.'
        it 'ceth delete fails' do
          ceth('delete').should_fail "FATAL: Must specify at least one argument.  If you want to delete everything in this directory, type \"ceth delete --recurse .\"\n", :stdout => /USAGE/
          ceth('list -Rf /').should_succeed <<EOM
clients
clients/seth-validator.json
clients/seth-webui.json
clients/x.json
cookbooks
cookbooks/x
cookbooks/x/metadata.rb
data_bags
data_bags/x
data_bags/x/y.json
environments
environments/_default.json
environments/x.json
nodes
nodes/x.json
roles
roles/x.json
users
users/admin.json
users/x.json
EOM
          ceth('list -Rf --local /').should_succeed <<EOM
clients
cookbooks
data_bags
environments
nodes
roles
users
EOM
        end
      end
    end
  end

  when_the_seth_server 'is empty' do
    when_the_repository 'has one of each thing' do
      file 'clients/x.json', {}
      file 'cookbooks/x/metadata.rb', ''
      file 'data_bags/x/y.json', {}
      file 'environments/_default.json', {}
      file 'environments/x.json', {}
      file 'nodes/x.json', {}
      file 'roles/x.json', {}
      file 'users/x.json', {}

      it 'ceth delete --both /cookbooks/x fails' do
        ceth('delete --both /cookbooks/x').should_fail "ERROR: /cookbooks/x (local) must be deleted recursively!  Pass -r to ceth delete.\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /cookbooks/x deletes x' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /data_bags/x fails' do
        ceth('delete --both /data_bags/x').should_fail "ERROR: /data_bags/x (local) must be deleted recursively!  Pass -r to ceth delete.\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /data_bags/x deletes x' do
        ceth('delete --both -r /data_bags/x').should_succeed "Deleted /data_bags/x\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /environments/x.json deletes x' do
        ceth('delete --both /environments/x.json').should_succeed "Deleted /environments/x.json\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /roles/x.json deletes x' do
        ceth('delete --both /roles/x.json').should_succeed "Deleted /roles/x.json\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/_default.json
/environments/x.json
/nodes
/nodes/x.json
/roles
/users
/users/x.json
EOM
      end

      it 'ceth delete --both /environments/_default.json fails but still deletes the local copy' do
        ceth('delete --both /environments/_default.json').should_fail :stderr => "ERROR: /environments/_default.json (remote) cannot be deleted (default environment cannot be modified).\n", :stdout => "Deleted /environments/_default.json\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed <<EOM
/clients
/clients/x.json
/cookbooks
/cookbooks/x
/cookbooks/x/metadata.rb
/data_bags
/data_bags/x
/data_bags/x/y.json
/environments
/environments/x.json
/nodes
/nodes/x.json
/roles
/roles/x.json
/users
/users/x.json
EOM
      end

      it 'ceth delete --both / fails' do
        ceth('delete --both /').should_fail "ERROR: / (remote) cannot be deleted.\nERROR: / (local) cannot be deleted.\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both -r /* fails' do
        ceth('delete --both -r /*').should_fail <<EOM
ERROR: / (remote) cannot be deleted.
ERROR: / (local) cannot be deleted.
ERROR: /clients (remote) cannot be deleted.
ERROR: /clients (local) cannot be deleted.
ERROR: /cookbooks (remote) cannot be deleted.
ERROR: /cookbooks (local) cannot be deleted.
ERROR: /data_bags (remote) cannot be deleted.
ERROR: /data_bags (local) cannot be deleted.
ERROR: /environments (remote) cannot be deleted.
ERROR: /environments (local) cannot be deleted.
ERROR: /nodes (remote) cannot be deleted.
ERROR: /nodes (local) cannot be deleted.
ERROR: /roles (remote) cannot be deleted.
ERROR: /roles (local) cannot be deleted.
ERROR: /users (remote) cannot be deleted.
ERROR: /users (local) cannot be deleted.
EOM
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed everything
      end

      it 'ceth delete --both /environments/nonexistent.json fails' do
        ceth('delete --both /environments/nonexistent.json').should_fail "ERROR: /environments/nonexistent.json: No such file or directory\n"
        ceth('list -Rf /').should_succeed server_nothing
        ceth('list -Rf --local /').should_succeed everything
      end

      context 'and cwd is at the top level' do
        cwd '.'
        it 'ceth delete fails' do
          ceth('delete').should_fail "FATAL: Must specify at least one argument.  If you want to delete everything in this directory, type \"ceth delete --recurse .\"\n", :stdout => /USAGE/
          ceth('list -Rf /').should_succeed <<EOM
clients
clients/seth-validator.json
clients/seth-webui.json
cookbooks
data_bags
environments
environments/_default.json
nodes
roles
users
users/admin.json
EOM
          ceth('list -Rf --local /').should_succeed <<EOM
clients
clients/x.json
cookbooks
cookbooks/x
cookbooks/x/metadata.rb
data_bags
data_bags/x
data_bags/x/y.json
environments
environments/_default.json
environments/x.json
nodes
nodes/x.json
roles
roles/x.json
users
users/x.json
EOM
        end
      end
    end
  end

  when_the_repository 'has a cookbook' do
    file 'cookbooks/x/metadata.rb', 'version "1.0.0"'
    file 'cookbooks/x/onlyin1.0.0.rb', 'old_text'

    when_the_seth_server 'has a later version for the cookbook' do
      cookbook 'x', '1.0.0', { 'metadata.rb' => 'version "1.0.0"', 'onlyin1.0.0.rb' => '' }
      cookbook 'x', '1.0.1', { 'metadata.rb' => 'version "1.0.1"', 'onlyin1.0.1.rb' => 'hi' }

      # TODO this seems wrong
      it 'ceth delete --both -r /cookbooks/x deletes the latest version on the server and the local version' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('raw /cookbooks/x').should_succeed(/1.0.0/)
        ceth('list --local /cookbooks').should_succeed ''
      end
    end

    when_the_seth_server 'has an earlier version for the cookbook' do
      cookbook 'x', '1.0.0', { 'metadata.rb' => 'version "1.0.0"', 'onlyin1.0.0.rb' => ''}
      cookbook 'x', '0.9.9', { 'metadata.rb' => 'version "0.9.9"', 'onlyin0.9.9.rb' => 'hi' }

      it 'ceth delete --both /cookbooks/x deletes the latest version on the server and the local version' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('raw /cookbooks/x').should_succeed(/0.9.9/)
        ceth('list --local /cookbooks').should_succeed ''
      end
    end

    when_the_seth_server 'has a later version for the cookbook, and no current version' do
      cookbook 'x', '1.0.1', { 'metadata.rb' => 'version "1.0.1"', 'onlyin1.0.1.rb' => 'hi' }

      it 'ceth delete --both /cookbooks/x deletes the server and client version of the cookbook' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('raw /cookbooks/x').should_fail(/404/)
        ceth('list --local /cookbooks').should_succeed ''
      end
    end

    when_the_seth_server 'has an earlier version for the cookbook, and no current version' do
      cookbook 'x', '0.9.9', { 'metadata.rb' => 'version "0.9.9"', 'onlyin0.9.9.rb' => 'hi' }

      it 'ceth delete --both /cookbooks/x deletes the server and client version of the cookbook' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('raw /cookbooks/x').should_fail(/404/)
        ceth('list --local /cookbooks').should_succeed ''
      end
    end
  end

  when_the_repository 'is empty' do
    when_the_seth_server 'has two versions of a cookbook' do
      cookbook 'x', '2.0.11', { 'metadata.rb' => 'version "2.0.11"' }
      cookbook 'x', '11.0.0', { 'metadata.rb' => 'version "11.0.0"' }
      it 'ceth delete deletes the latest version' do
        ceth('delete --both -r /cookbooks/x').should_succeed "Deleted /cookbooks/x\n"
        ceth('raw /cookbooks/x').should_succeed /2.0.11/
      end
    end
  end
end
