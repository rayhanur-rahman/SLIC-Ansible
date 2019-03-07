require_relative 'resource_couchdb_base'

class Chef
  class Resource
    class CouchdbReplication < Chef::Resource::CouchdbBase

      def initialize(name, run_context=nil)
        super
        @resource_name = :couchdb_replication
        @provider = Chef::Provider::CouchdbReplication
        @action = :create
        @allowed_actions  = [:create]
      end

      def source(arg=nil)
        set_or_return(:source,
                      arg,
                      kind_of: String,
                      name_attribute: true)
      end

      def target(arg=nil)
        set_or_return(:target,
                      arg,
                      kind_of: String,
                      required: true)
      end

      def replicator_db(arg=nil)
        set_or_return(:replicator_db,
                      arg,
                      kind_of: String,
                      default: '_replicator')
      end

      def continuous(arg=nil)
        set_or_return(:continuous,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: false)
      end

      def create_target(arg=nil)
        set_or_return(:create_target,
                      arg,
                      kind_of: [TrueClass, FalseClass])
      end

      def doc_ids(arg=nil)
        set_or_return(:doc_ids,
                      arg,
                      kind_of: Array)
      end

      def proxy(arg=nil)
        set_or_return(:proxy,
                      arg,
                      kind_of: String)
      end

      def since_seq(arg=nil)
        set_or_return(:since_seq,
                      arg,
                      kind_of: Integer)
      end

      def filter(arg=nil)
        set_or_return(:filter,
                      arg,
                      kind_of: String)
      end

      def query_params(arg=nil)
        set_or_return(:query_params,
                      arg,
                      kind_of: Hash)
      end

      def use_checkpoints(arg=nil)
        set_or_return(:use_checkpoints,
                      arg,
                      kind_of: [TrueClass, FalseClass])
      end

      def checkpoint_interval(arg=nil)
        set_or_return(:checkpoint_interval,
                      arg,
                      kind_of: Integer)
      end
    end
  end
end
