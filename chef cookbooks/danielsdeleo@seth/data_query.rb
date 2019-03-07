#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'seth/search/query'
require 'seth/data_bag'
require 'seth/data_bag_item'
require 'seth/encrypted_data_bag_item'

class Seth
  module DSL

    # ==Seth::DSL::DataQuery
    # Provides DSL for querying data from the seth-server via search or data
    # bag.
    module DataQuery

      def search(*args, &block)
        # If you pass a block, or have at least the start argument, do raw result parsing
        #
        # Otherwise, do the iteration for the end user
        if Kernel.block_given? || args.length >= 4
          Seth::Search::Query.new.search(*args, &block)
        else
          results = Array.new
          Seth::Search::Query.new.search(*args) do |o|
            results << o
          end
          results
        end
      end

      def data_bag(bag)
        DataBag.validate_name!(bag.to_s)
        rbag = DataBag.load(bag)
        rbag.keys
      rescue Exception
        Log.error("Failed to list data bag items in data bag: #{bag.inspect}")
        raise
      end

      def data_bag_item(bag, item)
        DataBag.validate_name!(bag.to_s)
        DataBagItem.validate_id!(item)
        DataBagItem.load(bag, item)
      rescue Exception
        Log.error("Failed to load data bag item: #{bag.inspect} #{item.inspect}")
        raise
      end
    end
  end
end

# **DEPRECATED**
# This used to be part of seth/mixin/language. Load the file to activate the deprecation code.
require 'seth/mixin/language'

