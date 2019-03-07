#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'seth/ceth'
require 'seth/ceth/core/node_presenter'

class Seth
  class ceth
    class NodeShow < ceth

      include ceth::Core::NodeFormattingOptions
      include ceth::Core::MultiAttributeReturnOption

      deps do
        require 'seth/node'
        require 'seth/json_compat'
      end

      banner "ceth node show NODE (options)"

      option :run_list,
        :short => "-r",
        :long => "--run-list",
        :description => "Show only the run list"

      option :environment,
        :short        => "-E",
        :long         => "--environment",
        :description  => "Show only the Seth environment"

      def run
        ui.use_presenter ceth::Core::NodePresenter
        @node_name = @name_args[0]

        if @node_name.nil?
          show_usage
          ui.fatal("You must specify a node name")
          exit 1
        end

        node = Seth::Node.load(@node_name)
        output(format_for_display(node))
        self.class.attrs_to_show = []
      end

      def self.attrs_to_show=(attrs)
        @attrs_to_show = attrs
      end
    end
  end
end

