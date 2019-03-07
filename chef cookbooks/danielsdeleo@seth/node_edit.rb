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

class Seth
  class ceth

    class NodeEdit < ceth

      deps do
        require 'seth/node'
        require 'seth/json_compat'
        require 'seth/ceth/core/node_editor'
      end

      banner "ceth node edit NODE (options)"

      option :all_attributes,
        :short => "-a",
        :long => "--all",
        :boolean => true,
        :description => "Display all attributes when editing"

      def run
        if node_name.nil?
          show_usage
          ui.fatal("You must specify a node name")
          exit 1
        end

        updated_node = node_editor.edit_node
        if updated_values = node_editor.updated?
          ui.info "Saving updated #{updated_values.join(', ')} on node #{node.name}"
          updated_node.save
        else
          ui.info "Node not updated, skipping node save"
        end
      end

      def node_name
        @node_name ||= @name_args[0]
      end

      def node_editor
        @node_editor ||= ceth::NodeEditor.new(node, ui, config)
      end

      def node
        @node ||= Seth::Node.load(node_name)
      end

    end
  end
end

