#
# Author:: Adam Jacob (<adam@opscode.com>)
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

require 'seth/handler'
require 'seth/resource/directory'

class Seth
  class Handler
    class ErrorReport < ::Seth::Handler

      def report
        Seth::FileCache.store("failed-run-data.json", seth::JSONCompat.to_json_pretty(data), 0640)
        Seth::Log.fatal("Saving node information to #{seth::FileCache.load("failed-run-data.json", false)}")
      end

    end
  end
end
