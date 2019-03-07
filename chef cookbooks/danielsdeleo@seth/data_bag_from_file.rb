#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Seth Falcon (<seth@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'seth/ceth'

class Seth
  class ceth
    class DataBagFromFile < ceth

      deps do
        require 'seth/data_bag'
        require 'seth/data_bag_item'
        require 'seth/ceth/core/object_loader'
        require 'seth/json_compat'
        require 'seth/encrypted_data_bag_item'
      end

      banner "ceth data bag from file BAG FILE|FOLDER [FILE|FOLDER..] (options)"
      category "data bag"

      option :secret,
        :short => "-s SECRET",
        :long  => "--secret ",
        :description => "The secret key to use to encrypt data bag item values",
        :proc => Proc.new { |s| Seth::Config[:ceth][:secret] = s }

      option :secret_file,
        :long => "--secret-file SECRET_FILE",
        :description => "A file containing the secret key to use to encrypt data bag item values",
        :proc => Proc.new { |sf| Seth::Config[:ceth][:secret_file] = sf }

      option :all,
        :short => "-a",
        :long  => "--all",
        :description => "Upload all data bags or all items for specified data bags"

      def read_secret
        if config[:secret]
          config[:secret]
        else
          Seth::EncryptedDataBagItem.load_secret(config[:secret_file])
        end
      end

      def use_encryption
        if config[:secret] && config[:secret_file]
          ui.fatal("please specify only one of --secret, --secret-file")
          exit(1)
        end
        config[:secret] || config[:secret_file]
      end

      def loader
        @loader ||= ceth::Core::ObjectLoader.new(DataBagItem, ui)
      end

      def run
        if config[:all] == true
          load_all_data_bags(@name_args)
        else
          if @name_args.size < 2
            ui.msg(opt_parser)
            exit(1)
          end
          @data_bag = @name_args.shift
          load_data_bag_items(@data_bag, @name_args)
        end
      end

      private
      def data_bags_path
        @data_bag_path ||= "data_bags"
      end

      def find_all_data_bags
        loader.find_all_object_dirs("./#{data_bags_path}")
      end

      def find_all_data_bag_items(data_bag)
        loader.find_all_objects("./#{data_bags_path}/#{data_bag}")
      end

      def load_all_data_bags(args)
        data_bags = args.empty? ? find_all_data_bags : [args.shift]
        data_bags.each do |data_bag|
          load_data_bag_items(data_bag)
        end
      end

      def load_data_bag_items(data_bag, items = nil)
        items ||= find_all_data_bag_items(data_bag)
        item_paths = normalize_item_paths(items)
        item_paths.each do |item_path|
          item = loader.load_from("#{data_bags_path}", data_bag, item_path)
          item = if use_encryption
                   secret = read_secret
                   Seth::EncryptedDataBagItem.encrypt_data_bag_item(item, secret)
                 else
                   item
                 end
          dbag = Seth::DataBagItem.new
          dbag.data_bag(data_bag)
          dbag.raw_data = item
          dbag.save
          ui.info("Updated data_bag_item[#{dbag.data_bag}::#{dbag.id}]")
        end
      end

      def normalize_item_paths(args)
        paths = Array.new
        args.each do |path|
          if File.directory?(path)
            paths.concat(Dir.glob(File.join(path, "*.json")))
          else
            paths << path
          end
        end
        paths
      end
    end
  end
end
