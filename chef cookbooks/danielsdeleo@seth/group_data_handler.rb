require 'seth/seth_fs/data_handler/data_handler_base'
require 'seth/api_client'

class Seth
  module SethFS
    module DataHandler
      class GroupDataHandler < DataHandlerBase
        def normalize(group, entry)
          defaults = {
            'name' => remove_dot_json(entry.name),
            'groupname' => remove_dot_json(entry.name),
            'users' => [],
            'clients' => [],
            'groups' => [],
          }
          if entry.org
            defaults['orgname'] = entry.org
          end
          result = normalize_hash(group, defaults)
          if result['actors'] && result['actors'].sort.uniq == (result['users'] + result['clients']).sort.uniq
            result.delete('actors')
          end
          result
        end

        def normalize_for_put(group, entry)
          result = super(group, entry)
          result['actors'] = {
            'users' => result['users'],
            'clients' => result['clients'],
            'groups' => result['groups']
          }
          result.delete('users')
          result.delete('clients')
          result.delete('groups')
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
