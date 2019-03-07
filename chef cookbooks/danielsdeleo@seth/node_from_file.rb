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
    class NodeFromFile < ceth

      deps do
        require 'seth/node'
        require 'seth/json_compat'
        require 'seth/ceth/core/object_loader'
      end

      banner "ceth node from file FILE (options)"

      def loader
        @loader ||= ceth::Core::ObjectLoader.new(Seth::Node, ui)
      end

      def run
        updated = loader.load_from('nodes', @name_args[0])

        updated.save

        output(format_for_display(updated)) if config[:print_after]

        ui.info("Updated Node #{updated.name}!")
      end

    end
  end
end

