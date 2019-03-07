#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

class Seth
  class ceth
    class Help < Seth::ceth

      banner "ceth help [list|TOPIC]"

      def run
        if name_args.empty?
          ui.info "Usage: ceth SUBCOMMAND (options)"
          ui.msg ""
          # This command is atypical, the user is likely not interested in usage of
          # this command, but ceth in general. So hack the banner.
          opt_parser.banner = "General ceth Options:"
          ui.msg opt_parser.to_s
          ui.msg ""
          ui.info "For further help:"
          ui.info(<<-MOAR_HELP)
  ceth help list             list help topics
  ceth help ceth            show general ceth help
  ceth help TOPIC            display the manual for TOPIC
  ceth SUBCOMMAND --help     show the options for a command
MOAR_HELP
          exit 1
        else
          @query = name_args.join('-')
        end



        case @query
        when 'topics', 'list'
          print_help_topics
          exit 1
        when 'intro', 'ceth'
          @topic = 'ceth'
        else
          @topic = find_manpages_for_query(@query)
        end

        manpage_path = find_manpage_path(@topic)
        exec "man #{manpage_path}"
      end

      def help_topics
        # The list of help topics is generated by a rake task from the available man pages
        # This constant is provided in help_topics.rb which is automatically required/loaded by the ceth subcommand loader.
        HELP_TOPICS
      end

      def print_help_topics
        ui.info "Available help topics are: "
        help_topics.collect {|t| t.gsub(/ceth-/, '') }.sort.each do |topic|
          ui.msg "  #{topic}"
        end
      end

      def find_manpages_for_query(query)
        possibilities = help_topics.select do |manpage|
          ::File.fnmatch("ceth-#{query}*", manpage) || ::File.fnmatch("#{query}*", manpage)
        end
        if possibilities.empty?
          ui.error "No help found for '#{query}'"
          ui.msg ""
          print_help_topics
          exit 1
        elsif possibilities.size == 1
          possibilities.first
        else
          ui.info "Multiple help topics match your query. Pick one:"
          ui.highline.choose(*possibilities)
        end
      end

      def find_manpage_path(topic)
        if ::File.exists?(::File.expand_path("../distro/common/man/man1/#{topic}.1", seth_ROOT))
          # If we've provided the man page in the gem, give that
          return ::File.expand_path("../distro/common/man/man1/#{topic}.1", seth_ROOT)
        else
          # Otherwise, we'll just be using MANPATH
          topic
        end
      end
    end
  end
end
