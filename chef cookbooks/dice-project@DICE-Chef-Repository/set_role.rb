resource_name 'set_role'

property :dmon, String
property :role, String, name_property: true
property :hostname, String

action :run do
  http_request "Set #{new_resource.role} role for #{new_resource.hostname}" do
    action :put
    url "http://#{new_resource.dmon}/dmon/v1/overlord/nodes/roles"
    headers 'Content-Type' => 'application/json'
    message({
      Nodes: [
        NodeName: new_resource.hostname,
        Roles: [new_resource.role]
      ]
    }.to_json)
  end

  http_request 'Request Logstash restart' do
    action :post
    url "http://#{new_resource.dmon}/dmon/v2/overlord/core/ls"
    message ''
    headers 'Content-Type' => 'application/json'
  end
end
