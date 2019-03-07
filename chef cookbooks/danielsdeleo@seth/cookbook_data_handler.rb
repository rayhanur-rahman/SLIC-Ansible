require 'seth/seth_fs/data_handler/data_handler_base'
require 'seth/cookbook/metadata'

class Seth
  module SethFS
    module DataHandler
      class CookbookDataHandler < DataHandlerBase
        def normalize(cookbook, entry)
          version = entry.name
          name = entry.parent.name
          result = normalize_hash(cookbook, {
            'name' => "#{name}-#{version}",
            'version' => version,
            'cookbook_name' => name,
            'json_class' => 'Seth::CookbookVersion',
            'seth_type' => 'cookbook_version',
            'frozen?' => false,
            'metadata' => {}
          })
          result['metadata'] = normalize_hash(result['metadata'], {
            'version' => version,
            'name' => name
          })
        end

        def preserve_key(key)
          return key == 'cookbook_name' || key == 'version'
        end

        def seth_class
          Seth::Cookbook::Metadata
        end

        # Not using this yet, so not sure if to_ruby will be useful.
      end
    end
  end
end
