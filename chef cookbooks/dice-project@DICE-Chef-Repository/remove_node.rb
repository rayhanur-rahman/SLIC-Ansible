resource_name 'remove_node'

property :dmon, String
property :hostname, String, name_property: true

action :run do
  http_request "Remove node #{new_resource.hostname} from DMon master" do
    action :delete
    url "http://#{new_resource.dmon}/dmon/v1/overlord/"\
      "nodes/#{new_resource.hostname}"
    message ''
    headers 'Content-Type' => 'application/json'
  end

  http_request 'Request Logstash restart (node removal)' do
    action :post
    url "http://#{new_resource.dmon}/dmon/v2/overlord/core/ls"
    message ''
    headers 'Content-Type' => 'application/json'
  end
end
