require_relative 'resource_couchdb_base'

class Chef
  class Resource
    class CouchdbConfig < Chef::Resource::CouchdbBase

      def initialize(name, run_context=nil)
        super
        @resource_name = :couchdb_config
        @provider = Chef::Provider::CouchdbConfig
        @action = :create
        @allowed_actions  = [:create, :delete]
      end

      def section(arg=nil)
        set_or_return(:section,
                      arg,
                      kind_of: String,
                      required: true)
      end

      def key(arg=nil)
        set_or_return(:key,
                      arg,
                      kind_of: String,
                      required: true)
      end

      def value(arg=nil)
        set_or_return(:value,
                      arg,
                      kind_of: String,
                      required: true)
      end
    end
  end
end
