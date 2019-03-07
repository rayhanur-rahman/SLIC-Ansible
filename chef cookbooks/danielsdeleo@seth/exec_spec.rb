#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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
require 'tiny_server'

describe Seth::ceth::Exec do
  before(:all) do
    @server = TinyServer::Manager.new#(:debug => true)
    @server.start
  end

  before(:each) do
    @ceth = Seth::ceth::Exec.new
    @api = TinyServer::API.instance
    @api.clear

    Seth::Config[:node_name] = nil
    Seth::Config[:client_key] = nil
    Seth::Config[:seth_server_url] = 'http://localhost:9000'

    $output = StringIO.new
  end

  after(:all) do
    @server.stop
  end

  pending "executes a script in the context of the seth-shell main context", :ruby_18_only

  it "executes a script in the context of the seth-shell main context", :ruby_gte_19_only do
    @node = Seth::Node.new
    @node.name("ohai-world")
    response = {"rows" => [@node],"start" => 0,"total" => 1}
    @api.get(%r{^/search/node}, 200, response.to_json)
    code = "$output.puts nodes.all"
    @ceth.config[:exec] = code
    @ceth.run
    $output.string.should match(%r{node\[ohai-world\]})
  end

end
