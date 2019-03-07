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
require 'seth/ceth/deps'

describe 'ceth deps' do
  extend IntegrationSupport
  include cethSupport

  context 'local' do
    when_the_repository 'has a role with no run_list' do
      file 'roles/starring.json', {}
      it 'ceth deps reports no dependencies' do
        ceth('deps /roles/starring.json').should_succeed "/roles/starring.json\n"
      end
    end

    when_the_repository 'has a role with a default run_list' do
      file 'roles/starring.json', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      file 'roles/minor.json', {}
      file 'cookbooks/quiche/metadata.rb', 'name "quiche"'
      file 'cookbooks/quiche/recipes/default.rb', ''
      file 'cookbooks/soup/metadata.rb', 'name "soup"'
      file 'cookbooks/soup/recipes/chicken.rb', ''
      it 'ceth deps reports all dependencies' do
        ceth('deps /roles/starring.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
EOM
      end
    end

    when_the_repository 'has a role with an env_run_list' do
      file 'roles/starring.json', { 'env_run_lists' => { 'desert' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) } }
      file 'roles/minor.json', {}
      file 'cookbooks/quiche/metadata.rb', 'name "quiche"'
      file 'cookbooks/quiche/recipes/default.rb', ''
      file 'cookbooks/soup/metadata.rb', 'name "soup"'
      file 'cookbooks/soup/recipes/chicken.rb', ''
      it 'ceth deps reports all dependencies' do
        ceth('deps /roles/starring.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
EOM
      end
    end

    when_the_repository 'has a node with no environment or run_list' do
      file 'nodes/mort.json', {}
      it 'ceth deps reports just the node' do
        ceth('deps /nodes/mort.json').should_succeed "/nodes/mort.json\n"
      end
    end
    when_the_repository 'has a node with an environment' do
      file 'environments/desert.json', {}
      file 'nodes/mort.json', { 'seth_environment' => 'desert' }
      it 'ceth deps reports just the node' do
        ceth('deps /nodes/mort.json').should_succeed "/environments/desert.json\n/nodes/mort.json\n"
      end
    end
    when_the_repository 'has a node with roles and recipes in its run_list' do
      file 'roles/minor.json', {}
      file 'cookbooks/quiche/metadata.rb', 'name "quiche"'
      file 'cookbooks/quiche/recipes/default.rb', ''
      file 'cookbooks/soup/metadata.rb', 'name "soup"'
      file 'cookbooks/soup/recipes/chicken.rb', ''
      file 'nodes/mort.json', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      it 'ceth deps reports just the node' do
        ceth('deps /nodes/mort.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/nodes/mort.json
EOM
      end
    end
    when_the_repository 'has a cookbook with no dependencies' do
      file 'cookbooks/quiche/metadata.rb', 'name "quiche"'
      file 'cookbooks/quiche/recipes/default.rb', ''
      it 'ceth deps reports just the cookbook' do
        ceth('deps /cookbooks/quiche').should_succeed "/cookbooks/quiche\n"
      end
    end
    when_the_repository 'has a cookbook with dependencies' do
      file 'cookbooks/kettle/metadata.rb', 'name "kettle"'
      file 'cookbooks/quiche/metadata.rb', "name 'quiche'\ndepends 'kettle'\n"
      file 'cookbooks/quiche/recipes/default.rb', ''
      it 'ceth deps reports just the cookbook' do
        ceth('deps /cookbooks/quiche').should_succeed "/cookbooks/kettle\n/cookbooks/quiche\n"
      end
    end
    when_the_repository 'has a data bag' do
      file 'data_bags/bag/item.json', {}
      it 'ceth deps reports just the data bag' do
        ceth('deps /data_bags/bag/item.json').should_succeed "/data_bags/bag/item.json\n"
      end
    end
    when_the_repository 'has an environment' do
      file 'environments/desert.json', {}
      it 'ceth deps reports just the environment' do
        ceth('deps /environments/desert.json').should_succeed "/environments/desert.json\n"
      end
    end
    when_the_repository 'has a deep dependency tree' do
      file 'roles/starring.json', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      file 'roles/minor.json', {}
      file 'cookbooks/quiche/metadata.rb', 'name "quiche"'
      file 'cookbooks/quiche/recipes/default.rb', ''
      file 'cookbooks/soup/metadata.rb', 'name "soup"'
      file 'cookbooks/soup/recipes/chicken.rb', ''
      file 'environments/desert.json', {}
      file 'nodes/mort.json', { 'seth_environment' => 'desert', 'run_list' => [ 'role[starring]' ] }
      file 'nodes/bart.json', { 'run_list' => [ 'role[minor]' ] }

      it 'ceth deps reports all dependencies' do
        ceth('deps /nodes/mort.json').should_succeed <<EOM
/environments/desert.json
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps * reports all dependencies of all things' do
        ceth('deps /nodes/*').should_succeed <<EOM
/roles/minor.json
/nodes/bart.json
/environments/desert.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps a b reports all dependencies of a and b' do
        ceth('deps /nodes/bart.json /nodes/mort.json').should_succeed <<EOM
/roles/minor.json
/nodes/bart.json
/environments/desert.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps --tree /* shows dependencies in a tree' do
        ceth('deps --tree /nodes/*').should_succeed <<EOM
/nodes/bart.json
  /roles/minor.json
/nodes/mort.json
  /environments/desert.json
  /roles/starring.json
    /roles/minor.json
    /cookbooks/quiche
    /cookbooks/soup
EOM
      end
      it 'ceth deps --tree --no-recurse shows only the first level of dependencies' do
        ceth('deps --tree --no-recurse /nodes/*').should_succeed <<EOM
/nodes/bart.json
  /roles/minor.json
/nodes/mort.json
  /environments/desert.json
  /roles/starring.json
EOM
      end
    end

    context 'circular dependencies' do
      when_the_repository 'has cookbooks with circular dependencies' do
        file 'cookbooks/foo/metadata.rb', "name 'foo'\ndepends 'bar'\n"
        file 'cookbooks/bar/metadata.rb', "name 'bar'\ndepends 'baz'\n"
        file 'cookbooks/baz/metadata.rb', "name 'baz'\ndepends 'foo'\n"
        file 'cookbooks/self/metadata.rb', "name 'self'\ndepends 'self'\n"
        it 'ceth deps prints each once' do
          ceth('deps /cookbooks/foo /cookbooks/self').should_succeed <<EOM
/cookbooks/baz
/cookbooks/bar
/cookbooks/foo
/cookbooks/self
EOM
        end
        it 'ceth deps --tree prints each once' do
          ceth('deps --tree /cookbooks/foo /cookbooks/self').should_succeed <<EOM
/cookbooks/foo
  /cookbooks/bar
    /cookbooks/baz
      /cookbooks/foo
/cookbooks/self
  /cookbooks/self
EOM
        end
      end
      when_the_repository 'has roles with circular dependencies' do
        file 'roles/foo.json', { 'run_list' => [ 'role[bar]' ] }
        file 'roles/bar.json', { 'run_list' => [ 'role[baz]' ] }
        file 'roles/baz.json', { 'run_list' => [ 'role[foo]' ] }
        file 'roles/self.json', { 'run_list' => [ 'role[self]' ] }
        it 'ceth deps prints each once' do
          ceth('deps /roles/foo.json /roles/self.json').should_succeed <<EOM
/roles/baz.json
/roles/bar.json
/roles/foo.json
/roles/self.json
EOM
        end
        it 'ceth deps --tree prints each once' do
          ceth('deps --tree /roles/foo.json /roles/self.json') do
            stdout.should == "/roles/foo.json\n  /roles/bar.json\n    /roles/baz.json\n      /roles/foo.json\n/roles/self.json\n  /roles/self.json\n"
            stderr.should == "WARNING: No ceth configuration file found\n"
          end
        end
      end
    end

    context 'missing objects' do
      when_the_repository 'is empty' do
        it 'ceth deps /blah reports an error' do
          ceth('deps /blah').should_fail(
            :exit_code => 2,
            :stdout => "/blah\n",
            :stderr => "ERROR: /blah: No such file or directory\n"
          )
        end
        it 'ceth deps /roles/x.json reports an error' do
          ceth('deps /roles/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/roles/x.json\n",
            :stderr => "ERROR: /roles/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /nodes/x.json reports an error' do
          ceth('deps /nodes/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/nodes/x.json\n",
            :stderr => "ERROR: /nodes/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /environments/x.json reports an error' do
          ceth('deps /environments/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/environments/x.json\n",
            :stderr => "ERROR: /environments/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /cookbooks/x reports an error' do
          ceth('deps /cookbooks/x').should_fail(
            :exit_code => 2,
            :stdout => "/cookbooks/x\n",
            :stderr => "ERROR: /cookbooks/x: No such file or directory\n"
          )
        end
        it 'ceth deps /data_bags/bag/item reports an error' do
          ceth('deps /data_bags/bag/item').should_fail(
            :exit_code => 2,
            :stdout => "/data_bags/bag/item\n",
            :stderr => "ERROR: /data_bags/bag/item: No such file or directory\n"
          )
        end
      end
      when_the_repository 'is missing a dependent cookbook' do
        file 'roles/starring.json', { 'run_list' => [ 'recipe[quiche]'] }
        it 'ceth deps reports the cookbook, along with an error' do
          ceth('deps /roles/starring.json').should_fail(
            :exit_code => 2,
            :stdout => "/cookbooks/quiche\n/roles/starring.json\n",
            :stderr => "ERROR: /cookbooks/quiche: No such file or directory\n"
          )
        end
      end
      when_the_repository 'is missing a dependent environment' do
        file 'nodes/mort.json', { 'seth_environment' => 'desert' }
        it 'ceth deps reports the environment, along with an error' do
          ceth('deps /nodes/mort.json').should_fail(
            :exit_code => 2,
            :stdout => "/environments/desert.json\n/nodes/mort.json\n",
            :stderr => "ERROR: /environments/desert.json: No such file or directory\n"
          )
        end
      end
      when_the_repository 'is missing a dependent role' do
        file 'roles/starring.json', { 'run_list' => [ 'role[minor]'] }
        it 'ceth deps reports the role, along with an error' do
          ceth('deps /roles/starring.json').should_fail(
            :exit_code => 2,
            :stdout => "/roles/minor.json\n/roles/starring.json\n",
            :stderr => "ERROR: /roles/minor.json: No such file or directory\n"
          )
        end
      end
    end
    context 'invalid objects' do
      when_the_repository 'is empty' do
        it 'ceth deps / reports itself only' do
          ceth('deps /').should_succeed("/\n")
        end
        it 'ceth deps /roles reports an error' do
          ceth('deps /roles').should_fail(
            :exit_code => 2,
            :stderr => "ERROR: /roles: No such file or directory\n",
            :stdout => "/roles\n"
          )
        end
      end
      when_the_repository 'has a data bag' do
        file 'data_bags/bag/item.json', ''
        it 'ceth deps /data_bags/bag shows no dependencies' do
          ceth('deps /data_bags/bag').should_succeed("/data_bags/bag\n")
        end
      end
      when_the_repository 'has a cookbook' do
        file 'cookbooks/blah/metadata.rb', 'name "blah"'
        it 'ceth deps on a cookbook file shows no dependencies' do
          ceth('deps /cookbooks/blah/metadata.rb').should_succeed(
            "/cookbooks/blah/metadata.rb\n"
          )
        end
      end
    end
  end

  context 'remote' do
    include_context "default config options"

    when_the_seth_server 'has a role with no run_list' do
      role 'starring', {}
      it 'ceth deps reports no dependencies' do
        ceth('deps --remote /roles/starring.json').should_succeed "/roles/starring.json\n"
      end
    end

    when_the_seth_server 'has a role with a default run_list' do
      role 'starring', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      role 'minor', {}
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\nversion '1.0.0'\n", 'recipes' => { 'default.rb' => '' } }
      cookbook 'soup', '1.0.0', { 'metadata.rb' => "name 'soup'\nversion '1.0.0'\n", 'recipes' => { 'chicken.rb' => '' } }
      it 'ceth deps reports all dependencies' do
        ceth('deps --remote /roles/starring.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
EOM
      end
    end

    when_the_seth_server 'has a role with an env_run_list' do
      role 'starring', { 'env_run_lists' => { 'desert' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) } }
      role 'minor', {}
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\nversion '1.0.0'\n", 'recipes' => { 'default.rb' => '' } }
      cookbook 'soup', '1.0.0', { 'metadata.rb' =>   "name 'soup'\nversion '1.0.0'\n", 'recipes' => { 'chicken.rb' => '' } }
      it 'ceth deps reports all dependencies' do
        ceth('deps --remote /roles/starring.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
EOM
      end
    end

    when_the_seth_server 'has a node with no environment or run_list' do
      node 'mort', {}
      it 'ceth deps reports just the node' do
        ceth('deps --remote /nodes/mort.json').should_succeed "/nodes/mort.json\n"
      end
    end
    when_the_seth_server 'has a node with an environment' do
      environment 'desert', {}
      node 'mort', { 'seth_environment' => 'desert' }
      it 'ceth deps reports just the node' do
        ceth('deps --remote /nodes/mort.json').should_succeed "/environments/desert.json\n/nodes/mort.json\n"
      end
    end
    when_the_seth_server 'has a node with roles and recipes in its run_list' do
      role 'minor', {}
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\nversion '1.0.0'\n", 'recipes' => { 'default.rb' => '' } }
      cookbook 'soup', '1.0.0', { 'metadata.rb' =>   "name 'soup'\nversion '1.0.0'\n", 'recipes' => { 'chicken.rb' => '' } }
      node 'mort', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      it 'ceth deps reports just the node' do
        ceth('deps --remote /nodes/mort.json').should_succeed <<EOM
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/nodes/mort.json
EOM
      end
    end
    when_the_seth_server 'has a cookbook with no dependencies' do
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\nversion '1.0.0'\n", 'recipes' => { 'default.rb' => '' } }
      it 'ceth deps reports just the cookbook' do
        ceth('deps --remote /cookbooks/quiche').should_succeed "/cookbooks/quiche\n"
      end
    end
    when_the_seth_server 'has a cookbook with dependencies' do
      cookbook 'kettle', '1.0.0', { 'metadata.rb' => "name 'kettle'\nversion '1.0.0'\n" }
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\ndepends 'kettle'\n", 'recipes' => { 'default.rb' => '' } }
      it 'ceth deps reports the cookbook and its dependencies' do
        ceth('deps --remote /cookbooks/quiche').should_succeed "/cookbooks/kettle\n/cookbooks/quiche\n"
      end
    end
    when_the_seth_server 'has a data bag' do
      data_bag 'bag', { 'item' => {} }
      it 'ceth deps reports just the data bag' do
        ceth('deps --remote /data_bags/bag/item.json').should_succeed "/data_bags/bag/item.json\n"
      end
    end
    when_the_seth_server 'has an environment' do
      environment 'desert', {}
      it 'ceth deps reports just the environment' do
        ceth('deps --remote /environments/desert.json').should_succeed "/environments/desert.json\n"
      end
    end
    when_the_seth_server 'has a deep dependency tree' do
      role 'starring', { 'run_list' => %w(role[minor] recipe[quiche] recipe[soup::chicken]) }
      role 'minor', {}
      cookbook 'quiche', '1.0.0', { 'metadata.rb' => "name 'quiche'\nversion '1.0.0'\n", 'recipes' => { 'default.rb' => '' } }
      cookbook 'soup', '1.0.0', { 'metadata.rb' =>   "name 'soup'\nversion '1.0.0'\n", 'recipes' => { 'chicken.rb' => '' } }
      environment 'desert', {}
      node 'mort', { 'seth_environment' => 'desert', 'run_list' => [ 'role[starring]' ] }
      node 'bart', { 'run_list' => [ 'role[minor]' ] }

      it 'ceth deps reports all dependencies' do
        ceth('deps --remote /nodes/mort.json').should_succeed <<EOM
/environments/desert.json
/roles/minor.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps * reports all dependencies of all things' do
        ceth('deps --remote /nodes/*').should_succeed <<EOM
/roles/minor.json
/nodes/bart.json
/environments/desert.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps a b reports all dependencies of a and b' do
        ceth('deps --remote /nodes/bart.json /nodes/mort.json').should_succeed <<EOM
/roles/minor.json
/nodes/bart.json
/environments/desert.json
/cookbooks/quiche
/cookbooks/soup
/roles/starring.json
/nodes/mort.json
EOM
      end
      it 'ceth deps --tree /* shows dependencies in a tree' do
        ceth('deps --remote --tree /nodes/*').should_succeed <<EOM
/nodes/bart.json
  /roles/minor.json
/nodes/mort.json
  /environments/desert.json
  /roles/starring.json
    /roles/minor.json
    /cookbooks/quiche
    /cookbooks/soup
EOM
      end
      it 'ceth deps --tree --no-recurse shows only the first level of dependencies' do
        ceth('deps --remote --tree --no-recurse /nodes/*').should_succeed <<EOM
/nodes/bart.json
  /roles/minor.json
/nodes/mort.json
  /environments/desert.json
  /roles/starring.json
EOM
      end
    end

    context 'circular dependencies' do
      when_the_seth_server 'has cookbooks with circular dependencies' do
        cookbook 'foo', '1.0.0', { 'metadata.rb'  => "name 'foo'\ndepends 'bar'\n" }
        cookbook 'bar', '1.0.0', { 'metadata.rb'  => "name 'bar'\ndepends 'baz'\n" }
        cookbook 'baz', '1.0.0', { 'metadata.rb'  => "name 'baz'\ndepends 'foo'\n" }
        cookbook 'self', '1.0.0', { 'metadata.rb' => "name 'self'\ndepends 'self'\n" }
        it 'ceth deps prints each once' do
          ceth('deps --remote /cookbooks/foo /cookbooks/self').should_succeed <<EOM
/cookbooks/baz
/cookbooks/bar
/cookbooks/foo
/cookbooks/self
EOM
        end
        it 'ceth deps --tree prints each once' do
          ceth('deps --remote --tree /cookbooks/foo /cookbooks/self').should_succeed <<EOM
/cookbooks/foo
  /cookbooks/bar
    /cookbooks/baz
      /cookbooks/foo
/cookbooks/self
  /cookbooks/self
EOM
        end
      end
      when_the_seth_server 'has roles with circular dependencies' do
        role 'foo', { 'run_list' => [ 'role[bar]' ] }
        role 'bar', { 'run_list' => [ 'role[baz]' ] }
        role 'baz', { 'run_list' => [ 'role[foo]' ] }
        role 'self', { 'run_list' => [ 'role[self]' ] }
        it 'ceth deps prints each once' do
          ceth('deps --remote /roles/foo.json /roles/self.json').should_succeed <<EOM
/roles/baz.json
/roles/bar.json
/roles/foo.json
/roles/self.json
EOM
        end
        it 'ceth deps --tree prints each once' do
          ceth('deps --remote --tree /roles/foo.json /roles/self.json') do
            stdout.should == "/roles/foo.json\n  /roles/bar.json\n    /roles/baz.json\n      /roles/foo.json\n/roles/self.json\n  /roles/self.json\n"
            stderr.should == "WARNING: No ceth configuration file found\n"
          end
        end
      end
    end

    context 'missing objects' do
      when_the_seth_server 'is empty' do
        it 'ceth deps /blah reports an error' do
          ceth('deps --remote /blah').should_fail(
            :exit_code => 2,
            :stdout => "/blah\n",
            :stderr => "ERROR: /blah: No such file or directory\n"
          )
        end
        it 'ceth deps /roles/x.json reports an error' do
          ceth('deps --remote /roles/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/roles/x.json\n",
            :stderr => "ERROR: /roles/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /nodes/x.json reports an error' do
          ceth('deps --remote /nodes/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/nodes/x.json\n",
            :stderr => "ERROR: /nodes/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /environments/x.json reports an error' do
          ceth('deps --remote /environments/x.json').should_fail(
            :exit_code => 2,
            :stdout => "/environments/x.json\n",
            :stderr => "ERROR: /environments/x.json: No such file or directory\n"
          )
        end
        it 'ceth deps /cookbooks/x reports an error' do
          ceth('deps --remote /cookbooks/x').should_fail(
            :exit_code => 2,
            :stdout => "/cookbooks/x\n",
            :stderr => "ERROR: /cookbooks/x: No such file or directory\n"
          )
        end
        it 'ceth deps /data_bags/bag/item reports an error' do
          ceth('deps --remote /data_bags/bag/item').should_fail(
            :exit_code => 2,
            :stdout => "/data_bags/bag/item\n",
            :stderr => "ERROR: /data_bags/bag/item: No such file or directory\n"
          )
        end
      end
      when_the_seth_server 'is missing a dependent cookbook' do
        role 'starring', { 'run_list' => [ 'recipe[quiche]'] }
        it 'ceth deps reports the cookbook, along with an error' do
          ceth('deps --remote /roles/starring.json').should_fail(
            :exit_code => 2,
            :stdout => "/cookbooks/quiche\n/roles/starring.json\n",
            :stderr => "ERROR: /cookbooks/quiche: No such file or directory\n"
          )
        end
      end
      when_the_seth_server 'is missing a dependent environment' do
        node 'mort', { 'seth_environment' => 'desert' }
        it 'ceth deps reports the environment, along with an error' do
          ceth('deps --remote /nodes/mort.json').should_fail(
            :exit_code => 2,
            :stdout => "/environments/desert.json\n/nodes/mort.json\n",
            :stderr => "ERROR: /environments/desert.json: No such file or directory\n"
          )
        end
      end
      when_the_seth_server 'is missing a dependent role' do
        role 'starring', { 'run_list' => [ 'role[minor]'] }
        it 'ceth deps reports the role, along with an error' do
          ceth('deps --remote /roles/starring.json').should_fail(
            :exit_code => 2,
            :stdout => "/roles/minor.json\n/roles/starring.json\n",
            :stderr => "ERROR: /roles/minor.json: No such file or directory\n"
          )
        end
      end
    end
    context 'invalid objects' do
      when_the_seth_server 'is empty' do
        it 'ceth deps / reports an error' do
          ceth('deps --remote /').should_succeed("/\n")
        end
        it 'ceth deps /roles reports an error' do
          ceth('deps --remote /roles').should_succeed("/roles\n")
        end
      end
      when_the_seth_server 'has a data bag' do
        data_bag 'bag', { 'item' => {} }
        it 'ceth deps /data_bags/bag shows no dependencies' do
          ceth('deps --remote /data_bags/bag').should_succeed("/data_bags/bag\n")
        end
      end
      when_the_seth_server 'has a cookbook' do
        cookbook 'blah', '1.0.0', { 'metadata.rb' => 'name "blah"' }
        it 'ceth deps on a cookbook file shows no dependencies' do
          ceth('deps --remote /cookbooks/blah/metadata.rb').should_succeed(
            "/cookbooks/blah/metadata.rb\n"
          )
        end
      end
    end
  end

  it 'ceth deps --no-recurse reports an error' do
    ceth('deps --no-recurse /').should_fail("ERROR: --no-recurse requires --tree\n")
  end
end
