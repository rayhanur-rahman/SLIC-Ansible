#
# Author:: AJ Christensen (<aj@opscode.com>)
# Author:: Mark Mzyk (mmzyk@opscode.com)
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

require 'seth'
require 'seth/application'
require 'seth/client'
require 'seth/config'
require 'seth/daemon'
require 'seth/log'
require 'seth/rest'
require 'seth/config_fetcher'
require 'fileutils'

class Seth::Application::Solo < seth::Application

  option :config_file,
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => Seth::Config.platform_specific_path('/etc/seth/solo.rb'),
    :description => "The configuration file to use"

  option :formatter,
    :short        => "-F FORMATTER",
    :long         => "--format FORMATTER",
    :description  => "output format to use",
    :proc         => lambda { |format| Seth::Config.add_formatter(format) }

  option :force_logger,
    :long         => "--force-logger",
    :description  => "Use logger output instead of formatter output",
    :boolean      => true,
    :default      => false

  option :force_formatter,
    :long         => "--force-formatter",
    :description  => "Use formatter output instead of logger output",
    :boolean      => true,
    :default      => false

  option :color,
    :long         => '--[no-]color',
    :boolean      => true,
    :default      => !Seth::Platform.windows?,
    :description  => "Use colored output, defaults to enabled"

  option :log_level,
    :short        => "-l LEVEL",
    :long         => "--log_level LEVEL",
    :description  => "Set the log level (debug, info, warn, error, fatal)",
    :proc         => lambda { |l| l.to_sym }

  option :log_location,
    :short        => "-L LOGLOCATION",
    :long         => "--logfile LOGLOCATION",
    :description  => "Set the log file location, defaults to STDOUT",
    :proc         => nil

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0

  option :user,
    :short => "-u USER",
    :long => "--user USER",
    :description => "User to set privilege to",
    :proc => nil

  option :group,
    :short => "-g GROUP",
    :long => "--group GROUP",
    :description => "Group to set privilege to",
    :proc => nil

  unless Seth::Platform.windows?
    option :daemonize,
      :short => "-d",
      :long => "--daemonize",
      :description => "Daemonize the process",
      :proc => lambda { |p| true }
  end

  option :interval,
    :short => "-i SECONDS",
    :long => "--interval SECONDS",
    :description => "Run seth-client periodically, in seconds",
    :proc => lambda { |s| s.to_i }

  option :json_attribs,
    :short => "-j JSON_ATTRIBS",
    :long => "--json-attributes JSON_ATTRIBS",
    :description => "Load attributes from a JSON file or URL",
    :proc => nil

  option :node_name,
    :short => "-N NODE_NAME",
    :long => "--node-name NODE_NAME",
    :description => "The node name for this client",
    :proc => nil

  option :splay,
    :short => "-s SECONDS",
    :long => "--splay SECONDS",
    :description => "The splay time for running at intervals, in seconds",
    :proc => lambda { |s| s.to_i }

  option :recipe_url,
      :short => "-r RECIPE_URL",
      :long => "--recipe-url RECIPE_URL",
      :description => "Pull down a remote gzipped tarball of recipes and untar it to the cookbook cache.",
      :proc => nil

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show seth version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Seth: #{::seth::VERSION}"},
    :exit         => 0

  option :override_runlist,
    :short        => "-o RunlistItem,RunlistItem...",
    :long         => "--override-runlist RunlistItem,RunlistItem...",
    :description  => "Replace current run list with specified items",
    :proc         => lambda{|items|
      items = items.split(',')
      items.compact.map{|item|
        Seth::RunList::RunListItem.new(item)
      }
    }

  option :client_fork,
    :short        => "-f",
    :long         => "--[no-]fork",
    :description  => "Fork client",
    :boolean      => true

  option :why_run,
    :short        => '-W',
    :long         => '--why-run',
    :description  => 'Enable whyrun mode',
    :boolean      => true

  option :environment,
    :short        => '-E ENVIRONMENT',
    :long         => '--environment ENVIRONMENT',
    :description  => 'Set the Seth Environment on the node'

  option :run_lock_timeout,
    :long         => "--run-lock-timeout SECONDS",
    :description  => "Set maximum duration to wait for another client run to finish, default is indefinitely.",
    :proc         => lambda { |s| s.to_i }

  attr_reader :seth_client_json

  def initialize
    super
  end

  def reconfigure
    super

    Seth::Config[:solo] = true

    if Seth::Config[:daemonize]
      Seth::Config[:interval] ||= 1800
    end

    if Seth::Config[:json_attribs]
      config_fetcher = Seth::ConfigFetcher.new(seth::Config[:json_attribs])
      @seth_client_json = config_fetcher.fetch_json
    end

    if Seth::Config[:recipe_url]
      cookbooks_path = Array(Seth::Config[:cookbook_path]).detect{|e| e =~ /\/cookbooks\/*$/ }
      recipes_path = File.expand_path(File.join(cookbooks_path, '..'))

      Seth::Log.debug "Creating path #{recipes_path} to extract recipes into"
      FileUtils.mkdir_p recipes_path
      path = File.join(recipes_path, 'recipes.tgz')
      File.open(path, 'wb') do |f|
        open(Seth::Config[:recipe_url]) do |r|
          f.write(r.read)
        end
      end
      Seth::Mixin::Command.run_command(:command => "tar zxvf #{path} -C #{recipes_path}")
    end
  end

  def setup_application
    Seth::Daemon.change_privilege
  end

  def run_application
    if Seth::Config[:daemonize]
      Seth::Daemon.daemonize("seth-client")
    end

    loop do
      begin
        if Seth::Config[:splay]
          splay = rand Seth::Config[:splay]
          Seth::Log.debug("Splay sleep #{splay} seconds")
          sleep splay
        end

        run_seth_client
        if Seth::Config[:interval]
          Seth::Log.debug("Sleeping for #{seth::Config[:interval]} seconds")
          sleep Seth::Config[:interval]
        else
          Seth::Application.exit! "Exiting", 0
        end
      rescue SystemExit => e
        raise
      rescue Exception => e
        if Seth::Config[:interval]
          Seth::Log.error("#{e.class}: #{e}")
          Seth::Log.debug("#{e.class}: #{e}\n#{e.backtrace.join("\n")}")
          Seth::Log.fatal("Sleeping for #{seth::Config[:interval]} seconds before trying again")
          sleep Seth::Config[:interval]
          retry
        else
          Seth::Application.fatal!("#{e.class}: #{e.message}", 1)
        end
      end
    end
  end

end
