#
# Author:: Ryan Davis (<ryand-ruby@zenspider.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Copyright:: Copyright (c) 2011 Ryan Davis and Opscode, Inc.
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
    class TagList < ceth

      deps do
        require 'seth/node'
      end

      banner "ceth tag list NODE"

      def run
        name = @name_args[0]

        if name.nil?
          show_usage
          ui.fatal("You must specify a node name.")
          exit 1
        end

        node = Seth::Node.load(name)
        output(node.tags)
      end
    end
  end
end
