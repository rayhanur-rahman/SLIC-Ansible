## http://docs.couchdb.org/en/latest/config/intro.html
## http://docs.couchdb.org/en/latest/api/server/configuration.html
require 'chef/provider'
require_relative 'helpers'

class Chef
  class Provider
    class CouchdbConfig < Chef::Provider::CouchdbBase
      include Couchdb::Helpers

      def load_current_resource
        @current_resource ||= Chef::Resource::CouchdbConfig.new(new_resource.name)
        @current_resource
      end

      def action_create
        if exist?
          new_resource.updated_by_last_action false
        else
          options[:body] = new_resource.value
          resp = couchdb_put(urn, host, options)
          if resp.is_a? Net::HTTPOK
            new_resource.updated_by_last_action true
          else
            fail "Unexpected response code #{resp.code}"
          end
        end
      end

      def action_delete
        if exist?
          resp = couchdb_delete(new_resource.database, host, options)
          if resp.is_a? Net::HTTPOK
            Chef::Log.debug('recieved a 200 from the couchdb server')
            new_resource.updated_by_last_action true
          else
            fail "Unexpected response code #{resp.code} while deleting database #{new_resource.database}"
          end
        else
          new_resource.updated_by_last_action false
        end
      end

      def urn
        return @urn unless @urn.nil?
        @urn = "_config/#{new_resource.section}/#{new_resource.key}"
      end

      def exist?
        resp = couchdb_get("_config/#{new_resource.section}", host, options)
        if resp.is_a? Net::HTTPOK
          Chef::Log.debug('recieved a 200 from couchdb server')
          result = JSON.parse(resp.body)

          if result == new_resource.value
            return true
          else
            return false
          end
        else
          fail "Unexpected response code #{resp.code} while querying #{resp.uri}"
        end
      end
    end
  end
end
