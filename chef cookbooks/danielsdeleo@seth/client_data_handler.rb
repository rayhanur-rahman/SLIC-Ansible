require 'seth/seth_fs/data_handler/data_handler_base'
require 'seth/api_client'

class Seth
  module SethFS
    module DataHandler
      class ClientDataHandler < DataHandlerBase
        def normalize(client, entry)
          defaults = {
            'name' => remove_dot_json(entry.name),
            'clientname' => remove_dot_json(entry.name),
            'admin' => false,
            'validator' => false,
            'seth_type' => 'client'
          }
          if entry.respond_to?(:org) && entry.org
            defaults['orgname'] = entry.org
          end
          result = normalize_hash(client, defaults)
          # You can NOT send json_class, or it will fail
          result.delete('json_class')
          result
        end

        def preserve_key(key)
          return key == 'name'
        end

        def seth_class
          Seth::ApiClient
        end

        # There is no Ruby API for Seth::ApiClient
      end
    end
  end
end
