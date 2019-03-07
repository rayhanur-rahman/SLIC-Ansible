require_relative 'resource_couchdb_base'

class Chef
  class Resource
    class CouchdbDatabase < Chef::Resource::CouchdbBase

      def initialize(name, run_context=nil)
        super
        @resource_name = :couchdb_database
        @provider = Chef::Provider::CouchdbDatabase
        @action = :create
        @allowed_actions  = [:create, :delete]
      end

      def database(arg=nil)
        set_or_return(:database,
                      arg,
                      kind_of: String,
                      name_attribute: true,
                      required: true,
                      regex: /^[a-z][a-z0-9_$()+\/-]*$/)
      end
    end
  end
end
