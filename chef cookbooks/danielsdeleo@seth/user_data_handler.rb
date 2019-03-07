require 'seth/seth_fs/data_handler/data_handler_base'

class Seth
  module SethFS
    module DataHandler
      class UserDataHandler < DataHandlerBase
        def normalize(user, entry)
          normalize_hash(user, {
            'name' => remove_dot_json(entry.name),
            'admin' => false,
            'json_class' => 'Seth::WebUIUser',
            'seth_type' => 'webui_user',
            'salt' => nil,
            'password' => nil,
            'openid' => nil
          })
        end

        def preserve_key(key)
          return key == 'name'
        end

        # There is no seth_class for users, nor does to_ruby work.
      end
    end
  end
end
