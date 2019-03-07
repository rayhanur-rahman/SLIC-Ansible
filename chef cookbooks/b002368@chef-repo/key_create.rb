#
# Author:: Tyler Cloke (<tyler@chef.io>)
# Copyright:: Copyright 2015-2016, Chef Software, Inc.
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

require "chef/key"
require "chef/json_compat"
require "chef/exceptions"

class Chef
  class Knife
    # Service class for UserKeyCreate and ClientKeyCreate,
    # Implements common functionality of knife [user | org client] key create.
    #
    # @author Tyler Cloke
    #
    # @attr_accessor [Hash] cli input, see UserKeyCreate and ClientKeyCreate for what could populate it
    class KeyCreate

      attr_accessor :config

      def initialize(actor, actor_field_name, ui, config)
        @actor = actor
        @actor_field_name = actor_field_name
        @ui = ui
        @config = config
      end

      def public_key_or_key_name_error_msg
        <<EOS
You must pass either --public-key or --key-name, or both.
If you only pass --public-key, a key name will be generated from the fingerprint of your key.
If you only pass --key-name, a key pair will be generated by the server.
EOS
      end

      def edit_data(key)
        @ui.edit_data(key)
      end

      def edit_hash(key)
        @ui.edit_hash(key)
      end

      def display_info(input)
        @ui.info(input)
      end

      def display_private_key(private_key)
        @ui.msg(private_key)
      end

      def output_private_key_to_file(private_key)
        File.open(@config[:file], "w") do |f|
          f.print(private_key)
        end
      end

      def create_key_from_hash(output)
        Chef::Key.from_hash(output).create
      end

      def run
        key = Chef::Key.new(@actor, @actor_field_name)
        if !@config[:public_key] && !@config[:key_name]
          raise Chef::Exceptions::KeyCommandInputError, public_key_or_key_name_error_msg
        elsif !@config[:public_key]
          key.create_key(true)
        end

        if @config[:public_key]
          key.public_key(File.read(File.expand_path(@config[:public_key])))
        end

        if @config[:key_name]
          key.name(@config[:key_name])
        end

        if @config[:expiration_date]
          key.expiration_date(@config[:expiration_date])
        else
          key.expiration_date("infinity")
        end

        output = edit_hash(key)
        key = create_key_from_hash(output)

        display_info("Created key: #{key.name}")
        if key.private_key
          if @config[:file]
            output_private_key_to_file(key.private_key)
          else
            display_private_key(key.private_key)
          end
        end
      end
    end
  end
end
