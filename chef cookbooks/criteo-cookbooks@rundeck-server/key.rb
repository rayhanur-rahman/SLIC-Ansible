=begin
#<
Manage rundeck key storage through rundeck api

@action create Create a key in storage
@action delete Delete key from storage

@section Examples

    rundeck_server_key 'mykey' do
      type 'private'
      content '---START.....'
      endpoint 'ttp://127.0.0.1:4440'
      api_token 'myticket''
      action :create
    end
#>
=end

# <> @property path to key
property :key,       String, name_property:  true
# <> @property type of key. Can be 'private', 'public'
property :type,      Symbol, required: true, default: :public, equal_to: [:public, :private]
# <> @property key data
property :content,   String, required: false
# <> @property endpoint
property :endpoint,  String, default: 'http://127.0.0.1:4440'
# <> @property api_token Token used to interact with the api. See rundeck documentation to generate a token.
property :api_token, String, required: true

action :create do
  require 'rundeck'

  client = Rundeck.client(endpoint: @new_resource.endpoint, api_token: @new_resource.api_token)
  if key_exists?(client, @new_resource.key)
    converge_by "Update storage key #{@new_resource.key}" do
      begin
        response = case @new_resource.type
        when :private
          client.update_private_key(@new_resource.key, @new_resource.content)
        when :public
          client.update_public_key(@new_resource.key, @new_resource.content)
        else
         fail 'Supported types: [:private, :public]'
        end
      rescue Rundeck::Error::Forbidden
        fail "Forbidden access to #{client.endpoint} with api token '#{client.api_token}'"
      end
      Chef::Log.debug('Result: ' + response.inspect)
    end

  else
    converge_by "Create storage key #{@new_resource.key}" do
      begin
        response = case @new_resource.type
        when :private
          client.create_private_key(@new_resource.key, @new_resource.content)
        when :public
          client.create_public_key(@new_resource.key, @new_resource.content)
        else
         fail 'Supported types: [:private, :public]'
        end
      rescue Rundeck::Error::Forbidden
        fail "Forbidden access to #{client.endpoint} with api token '#{client.api_token}'"
      end
      Chef::Log.debug('Result: ' + response.inspect)
    end
  end
end

action :delete do
  require 'rundeck'

  client = Rundeck.client(endpoint: @new_resource.endpoint, api_token: @new_resource.api_token)
  if key_exists?(client, @new_resource.key)
    converge_by "Delete storage key #{@new_resource.key}" do
      begin
        response = client.delete_key(@new_resource.key)
      rescue Rundeck::Error::Forbidden
        fail "Forbidden access to #{client.endpoint} with api token '#{client.api_token}'"
      end
      Chef::Log.debug('Result: ' + response.inspect)
    end
  end
end

def key_exists?(client, key)
  begin
    response = client.key_metadata(key)
  rescue Rundeck::Error::NotFound
    return false
  rescue Rundeck::Error::Forbidden
    fail "Forbidden access to #{client.endpoint} with api token '#{client.api_token}'"
  end
  Chef::Log.debug('Result: ' + response.inspect)
  true
end

