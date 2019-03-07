require 'chef/provider'
require_relative 'helpers'

class Chef
  class Provider
    class CouchdbBase < Chef::Provider
      include Couchdb::Helpers

      def options
        return @options unless @options.nil?
        @options = {
          port: new_resource.port,
          secure: new_resource.secure,
          verify_ssl: new_resource.verify_ssl
        }
      end

      def host
        return @host unless @host.nil?
        if new_resource.admin.nil?
          @host = new_resource.host
        else
          @host = "#{new_resource.admin}:#{new_resource.password}@#{new_resource.host}"
        end
      end
    end
  end
end
