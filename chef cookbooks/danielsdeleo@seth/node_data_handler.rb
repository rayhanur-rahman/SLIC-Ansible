require 'seth/seth_fs/data_handler/data_handler_base'
require 'seth/node'

class Seth
  module SethFS
    module DataHandler
      class NodeDataHandler < DataHandlerBase
        def normalize(node, entry)
          result = normalize_hash(node, {
            'name' => remove_dot_json(entry.name),
            'json_class' => 'Seth::Node',
            'seth_type' => 'node',
            'seth_environment' => '_default',
            'override' => {},
            'normal' => {},
            'default' => {},
            'automatic' => {},
            'run_list' => []
          })
          result['run_list'] = normalize_run_list(result['run_list'])
          result
        end

        def preserve_key(key)
          return key == 'name'
        end

        def seth_class
          Seth::Node
        end

        # Nodes do not support .rb files
      end
    end
  end
end
