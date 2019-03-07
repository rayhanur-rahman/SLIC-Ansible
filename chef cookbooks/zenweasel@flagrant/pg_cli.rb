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

class Chef
  module PgCLI
    def self.escape(string)
      string.to_s.gsub(/"/) {|m| "\\#{m}"}
    end

    def self.pg_command(command, options = {})
      args = []
      args << "--host=#{options[:host]}" if options[:host]
      args << "--port=#{options[:port]}" if options[:port]
      args << "--username=#{options[:admin_username]}" if options[:admin_username]
      args << "--dbname=#{options[:dbname]}" if options[:dbname]
      args << "--no-psqlrc"

      prefix = options[:admin_password] ? "PGPASSWORD=#{escape(options[:admin_password])} ": ''
      postfix = options[:match] ? " | grep '#{options[:match]}'": ''

      "echo \"#{escape(command)}\" | #{prefix}psql #{args.join(" ")}#{postfix}"
    end
  end
end

