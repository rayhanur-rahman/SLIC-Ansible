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
    class ClientDelete < ceth

      deps do
        require 'seth/api_client'
        require 'seth/json_compat'
      end

      option :delete_validators,
       :short => "-D",
       :long => "--delete-validators",
       :description => "Force deletion of client if it's a validator"

      banner "ceth client delete CLIENT (options)"

      def run
        @client_name = @name_args[0]

        if @client_name.nil?
          show_usage
          ui.fatal("You must specify a client name")
          exit 1
        end

        delete_object(Seth::ApiClient, @client_name, 'client') {
          object = Seth::ApiClient.load(@client_name)
          if object.validator
            unless config[:delete_validators]
              ui.fatal("You must specify --force to delete the validator client #{@client_name}")
              exit 2
            end
          end
          object.destroy
        }
      end

    end
  end
end
