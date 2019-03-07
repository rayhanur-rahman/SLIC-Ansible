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
    class Search < ceth

      include ceth::Core::MultiAttributeReturnOption

      deps do
        require 'seth/node'
        require 'seth/environment'
        require 'seth/api_client'
        require 'seth/search/query'
      end

      include ceth::Core::NodeFormattingOptions

      banner "ceth search INDEX QUERY (options)"

      option :sort,
        :short => "-o SORT",
        :long => "--sort SORT",
        :description => "The order to sort the results in",
        :default => nil

      option :start,
        :short => "-b ROW",
        :long => "--start ROW",
        :description => "The row to start returning results at",
        :default => 0,
        :proc => lambda { |i| i.to_i }

      option :rows,
        :short => "-R INT",
        :long => "--rows INT",
        :description => "The number of rows to return",
        :default => 1000,
        :proc => lambda { |i| i.to_i }

      option :run_list,
        :short => "-r",
        :long => "--run-list",
        :description => "Show only the run list"

      option :id_only,
        :short => "-i",
        :long => "--id-only",
        :description => "Show only the ID of matching objects"

      option :query,
        :short => "-q QUERY",
        :long => "--query QUERY",
        :description => "The search query; useful to protect queries starting with -"

      def run
        read_cli_args
        fuzzify_query

        if @type == 'node'
          ui.use_presenter ceth::Core::NodePresenter
        end


        q = Seth::Search::Query.new
        escaped_query = URI.escape(@query,
                           Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

        result_items = []
        result_count = 0

        rows = config[:rows]
        start = config[:start]
        begin
          q.search(@type, escaped_query, config[:sort], start, rows) do |item|
            formatted_item = format_for_display(item)
            # if formatted_item.respond_to?(:has_key?) && !formatted_item.has_key?('id')
            #   formatted_item['id'] = item.has_key?('id') ? item['id'] : item.name
            # end
            result_items << formatted_item
            result_count += 1
          end
        rescue Net::HTTPServerException => e
          msg = Seth::JSONCompat.from_json(e.response.body)["error"].first
          ui.error("ceth search failed: #{msg}")
          exit 1
        end

        if ui.interchange?
          output({:results => result_count, :rows => result_items})
        else
          ui.msg "#{result_count} items found"
          ui.msg("\n")
          result_items.each do |item|
            output(item)
            unless config[:id_only]
              ui.msg("\n")
            end
          end
        end
      end

      def read_cli_args
        if config[:query]
          if @name_args[1]
            ui.error "please specify query as an argument or an option via -q, not both"
            ui.msg opt_parser
            exit 1
          end
          @type = name_args[0]
          @query = config[:query]
        else
          case name_args.size
          when 0
            ui.error "no query specified"
            ui.msg opt_parser
            exit 1
          when 1
            @type = "node"
            @query = name_args[0]
          when 2
            @type = name_args[0]
            @query = name_args[1]
          end
        end
      end

      def fuzzify_query
        if @query !~ /:/
          @query = "tags:*#{@query}* OR roles:*#{@query}* OR fqdn:*#{@query}* OR addresses:*#{@query}*"
        end
      end

    end
  end
end




