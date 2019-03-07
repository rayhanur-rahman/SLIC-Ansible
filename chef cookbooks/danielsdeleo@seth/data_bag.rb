#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'seth/config'
require 'seth/mixin/params_validate'
require 'seth/mixin/from_file'
require 'seth/data_bag_item'
require 'seth/mash'
require 'seth/json_compat'

class Seth
  class DataBag

    include Seth::Mixin::FromFile
    include Seth::Mixin::ParamsValidate

    VALID_NAME = /^[\.\-[:alnum:]_]+$/

    def self.validate_name!(name)
      unless name =~ VALID_NAME
        raise Exceptions::InvalidDataBagName, "DataBags must have a name matching #{VALID_NAME.inspect}, you gave #{name.inspect}"
      end
    end

    # Create a new Seth::DataBag
    def initialize
      @name = ''
    end

    def name(arg=nil)
      set_or_return(
        :name,
        arg,
        :regex => VALID_NAME
      )
    end

    def to_hash
      result = {
        "name" => @name,
        'json_class' => self.class.name,
        "seth_type" => "data_bag",
      }
      result
    end

    # Serialize this object as a hash
    def to_json(*a)
      to_hash.to_json(*a)
    end

    def seth_server_rest
      Seth::REST.new(seth::Config[:seth_server_url])
    end

    def self.seth_server_rest
      Seth::REST.new(seth::Config[:seth_server_url])
    end

    # Create a Seth::Role from JSON
    def self.json_create(o)
      bag = new
      bag.name(o["name"])
      bag
    end

    def self.list(inflate=false)
      if Seth::Config[:solo]
        unless File.directory?(Seth::Config[:data_bag_path])
          raise Seth::Exceptions::InvalidDataBagPath, "Data bag path '#{seth::Config[:data_bag_path]}' is invalid"
        end

        names = Dir.glob(File.join(Seth::Config[:data_bag_path], "*")).map{|f|File.basename(f)}.sort
        names.inject({}) {|h, n| h[n] = n; h}
      else
        if inflate
          # Can't search for all data bags like other objects, fall back to N+1 :(
          list(false).inject({}) do |response, bag_and_uri|
            response[bag_and_uri.first] = load(bag_and_uri.first)
            response
          end
        else
          Seth::REST.new(seth::Config[:seth_server_url]).get_rest("data")
        end
      end
    end

    # Load a Data Bag by name via either the RESTful API or local data_bag_path if run in solo mode
    def self.load(name)
      if Seth::Config[:solo]
        unless File.directory?(Seth::Config[:data_bag_path])
          raise Seth::Exceptions::InvalidDataBagPath, "Data bag path '#{seth::Config[:data_bag_path]}' is invalid"
        end

        Dir.glob(File.join(Seth::Config[:data_bag_path], "#{name}", "*.json")).inject({}) do |bag, f|
          item = Seth::JSONCompat.from_json(IO.read(f))
          bag[item['id']] = item
          bag
        end
      else
        Seth::REST.new(seth::Config[:seth_server_url]).get_rest("data/#{name}")
      end
    end

    def destroy
      seth_server_rest.delete_rest("data/#{@name}")
    end

    # Save the Data Bag via RESTful API
    def save
      begin
        if Seth::Config[:why_run]
          Seth::Log.warn("In whyrun mode, so NOT performing data bag save.")
        else
          create
        end
      rescue Net::HTTPServerException => e
        raise e unless e.response.code == "409"
      end
      self
    end

    #create a data bag via RESTful API
    def create
      seth_server_rest.post_rest("data", self)
      self
    end

    # As a string
    def to_s
      "data_bag[#{@name}]"
    end

  end
end

