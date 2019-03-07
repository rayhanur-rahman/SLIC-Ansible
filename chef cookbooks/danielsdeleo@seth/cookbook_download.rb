#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2009, 2010 Opscode, Inc.
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
    class CookbookDownload < ceth

      attr_reader :version
      attr_accessor :cookbook_name

      deps do
        require 'seth/cookbook_version'
      end

      banner "ceth cookbook download COOKBOOK [VERSION] (options)"

      option :latest,
       :short => "-N",
       :long => "--latest",
       :description => "The version of the cookbook to download",
       :boolean => true

      option :download_directory,
       :short => "-d DOWNLOAD_DIRECTORY",
       :long => "--dir DOWNLOAD_DIRECTORY",
       :description => "The directory to download the cookbook into",
       :default => Dir.pwd

      option :force,
       :short => "-f",
       :long => "--force",
       :description => "Force download over the download directory if it exists"

      # TODO: tim/cw: 5-23-2010: need to implement ceth-side
      # specificity for downloads - need to implement --platform and
      # --fqdn here
      def run
        @cookbook_name, @version = @name_args

        if @cookbook_name.nil?
          show_usage
          ui.fatal("You must specify a cookbook name")
          exit 1
        elsif @version.nil?
          @version = determine_version
          if @version.nil?
            ui.fatal("No such cookbook found")
            exit 1
          end
        end

        ui.info("Downloading #{@cookbook_name} cookbook version #{@version}")

        cookbook = rest.get_rest("cookbooks/#{@cookbook_name}/#{@version}")
        manifest = cookbook.manifest

        basedir = File.join(config[:download_directory], "#{@cookbook_name}-#{cookbook.version}")
        if File.exists?(basedir)
          if config[:force]
            Seth::Log.debug("Deleting #{basedir}")
            FileUtils.rm_rf(basedir)
          else
            ui.fatal("Directory #{basedir} exists, use --force to overwrite")
            exit
          end
        end

        Seth::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
          next unless manifest.has_key?(segment)
          ui.info("Downloading #{segment}")
          manifest[segment].each do |segment_file|
            dest = File.join(basedir, segment_file['path'].gsub('/', File::SEPARATOR))
            Seth::Log.debug("Downloading #{segment_file['path']} to #{dest}")
            FileUtils.mkdir_p(File.dirname(dest))
            rest.sign_on_redirect = false
            tempfile = rest.get_rest(segment_file['url'], true)
            FileUtils.mv(tempfile.path, dest)
          end
        end
        ui.info("Cookbook downloaded to #{basedir}")
      end

      def determine_version

        if available_versions.nil?
          nil
        elsif available_versions.size == 1
          @version = available_versions.first
        elsif config[:latest]
          @version = available_versions.last
        else
          ask_which_version
        end
      end

      def available_versions
        @available_versions ||= begin
          versions = Seth::CookbookVersion.available_versions(@cookbook_name)
          unless versions.nil?
            versions.map! { |version| Seth::Version.new(version) }
            versions.sort!
          end
          versions
        end
        @available_versions
      end

      def ask_which_version
        question = "Which version do you want to download?\n"
        valid_responses = {}
        available_versions.each_with_index do |version, index|
          valid_responses[(index + 1).to_s] = version
          question << "#{index + 1}. #{@cookbook_name} #{version}\n"
        end
        question += "\n"
        response = ask_question(question).strip

        unless @version = valid_responses[response]
          ui.error("'#{response}' is not a valid value.")
          exit(1)
        end
        @version
      end

    end
  end
end
