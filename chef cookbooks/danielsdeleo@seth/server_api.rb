#
# Author:: John Keiser (<jkeiser@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

require 'seth/http'
require 'seth/http/authenticator'
require 'seth/http/cookie_manager'
require 'seth/http/decompressor'
require 'seth/http/json_input'
require 'seth/http/json_output'
require 'seth/http/remote_request_id'

class Seth
  class ServerAPI < Seth::HTTP

    def initialize(url = Seth::Config[:seth_server_url], options = {})
      options[:client_name] ||= Seth::Config[:node_name]
      options[:signing_key_filename] ||= Seth::Config[:client_key]
      super(url, options)
    end

    use Seth::HTTP::JSONInput
    use Seth::HTTP::JSONOutput
    use Seth::HTTP::CookieManager
    use Seth::HTTP::Decompressor
    use Seth::HTTP::Authenticator
    use Seth::HTTP::RemoteRequestID
  end
end
