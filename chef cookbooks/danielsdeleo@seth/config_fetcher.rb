require 'seth/application'
require 'seth/seth_fs/path_utils'
require 'seth/http/simple'
require 'seth/json_compat'

class Seth
  class ConfigFetcher

    attr_reader :config_location
    attr_reader :config_file_jail

    def initialize(config_location, config_file_jail=nil)
      @config_location = config_location
      @config_file_jail = config_file_jail
    end

    def fetch_json
      config_data = read_config
      begin
        Seth::JSONCompat.from_json(config_data)
      rescue JSON::ParserError => error
        Seth::Application.fatal!("Could not parse the provided JSON file (#{config_location}): " + error.message, 2)
      end
    end

    def read_config
      if remote_config?
        fetch_remote_config
      else
        read_local_config
      end
    end

    def fetch_remote_config
      http.get("")
    rescue SocketError, SystemCallError, Net::HTTPServerException => error
      Seth::Application.fatal!("Cannot fetch config '#{config_location}': '#{error.class}: #{error.message}", 2)
    end

    def read_local_config
      ::File.read(config_location)
    rescue Errno::ENOENT => error
      Seth::Application.fatal!("Cannot load configuration from #{config_location}", 2)
    rescue Errno::EACCES => error
      Seth::Application.fatal!("Permissions are incorrect on #{config_location}. Please chmod a+r #{config_location}", 2)
    end

    def config_missing?
      return false if remote_config?

      # Check if the config file exists, and check if it is underneath the config file jail
      begin
        real_config_file = Pathname.new(config_location).realpath.to_s
      rescue Errno::ENOENT
        return true
      end

      # If realpath succeeded, the file exists
      return false if !config_file_jail

      begin
        real_jail = Pathname.new(config_file_jail).realpath.to_s
      rescue Errno::ENOENT
        Seth::Log.warn("Config file jail #{config_file_jail} does not exist: will not load any config file.")
        return true
      end

      !Seth::sethFS::PathUtils.descendant_of?(real_config_file, real_jail)
    end

    def http
      Seth::HTTP::Simple.new(config_location)
    end

    def remote_config?
      !!(config_location =~ %r{^(http|https)://})
    end
  end
end
