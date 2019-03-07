require_relative 'provider_couchdb_base'

class Chef
  class Provider
    class CouchdbReplication < Chef::Provider::CouchdbBase
      include Couchdb::Helpers

      def load_current_resource
        @current_resource ||= Chef::Resource::CouchdbReplication.new(new_resource.name)
        @current_resource
      end

      def action_create
        if exist?
          ## TODO: Support updating the config
          new_resource.updated_by_last_action false
        else
          options[:body] = body
          resp = couchdb_post(new_resource.replicator_db, host, options)
          if resp.is_a? Net::HTTPCreated
            new_resource.updated_by_last_action true
          else
            fail "Unexpected response code #{resp.code}"
          end
        end
      end

      def exist?
        resp = couchdb_get("#{new_resource.replicator_db}/_all_docs", host, options)
        if resp.is_a? Net::HTTPOK
          Chef::Log.debug('recieved a 200 from couchdb server')
          result = JSON.parse(resp.body)

          result['rows'].each do |row|
            return true if row['id'] == id
          end

          return false
        else
          fail "Unexpected response code #{resp.code} while querying #{resp.uri}"
        end
      end

      def id
        return @id unless @id.nil?
        @id = "rep_#{new_resource.name}"
      end

      ## Build request body based on parameters set
      def body
        return @body unless @body.nil?
        @body = {
          'id' => id,
          'target' => new_resource.target,
          'source' => new_resource.source
        }
        %w(
          create_target
          continuous
          doc_ids
          proxy
          since_seq
          filter
          query_params
          use_checkpoints
          checkpoint_interval
        ).each do |param|
          res = new_resource.send(param.to_sym)
          @body[param] = res unless res.nil?
        end
        return @body
      end
    end
  end
end
