require 'seth/seth_fs/data_handler/data_handler_base'
require 'seth/data_bag_item'

class Seth
  module SethFS
    module DataHandler
      class DataBagItemDataHandler < DataHandlerBase
        def normalize(data_bag_item, entry)
          # If it's wrapped with raw_data, unwrap it.
          if data_bag_item['json_class'] == 'Seth::DataBagItem' && data_bag_item['raw_data']
            data_bag_item = data_bag_item['raw_data']
          end
          # seth_type and data_bag come back in PUT and POST results, but we don't
          # use those in ceth-essentials.
          normalize_hash(data_bag_item, {
            'id' => remove_dot_json(entry.name)
          })
        end

        def normalize_for_post(data_bag_item, entry)
          if data_bag_item['json_class'] == 'Seth::DataBagItem' && data_bag_item['raw_data']
            data_bag_item = data_bag_item['raw_data']
          end
          {
            "name" => "data_bag_item_#{entry.parent.name}_#{remove_dot_json(entry.name)}",
            "json_class" => "Seth::DataBagItem",
            "seth_type" => "data_bag_item",
            "data_bag" => entry.parent.name,
            "raw_data" => normalize(data_bag_item, entry)
          }
        end

        def normalize_for_put(data_bag_item, entry)
          normalize_for_post(data_bag_item, entry)
        end

        def preserve_key(key)
          return key == 'id'
        end

        def seth_class
          Seth::DataBagItem
        end

        def verify_integrity(object, entry, &on_error)
          base_name = remove_dot_json(entry.name)
          if object['raw_data']['id'] != base_name
            on_error.call("ID in #{entry.path_for_printing} must be '#{base_name}' (is '#{object['raw_data']['id']}')")
          end
        end

        # Data bags do not support .rb files (or if they do, it's undocumented)
      end
    end
  end
end
