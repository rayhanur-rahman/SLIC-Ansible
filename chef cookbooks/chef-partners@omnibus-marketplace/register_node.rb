if File.exist?("/etc/chef-marketplace/marketplace.rb")
  Marketplace.from_file("/etc/chef-marketplace/marketplace.rb")
end

node.consume_attributes("chef-marketplace" => Marketplace.save(false))

include_recipe "chef-marketplace::_config_api_fqdn"

if outbound_traffic_disabled?
  Chef::Log.warn "Skipping node registration because outbound traffic is disabled"
  return
end

ruby_block "register node" do
  block do
    require "marketplace/api_client"

    # Build a valid params hash
    #  {
    #    'user' => {
    #      'first_name' => 'foo',
    #      'last_name' => 'bar',
    #      'email' => 'foo@bar.com'
    #      'organization' => 'Acme, Inc.'
    #    },
    #    'node' => {
    #      'platform' => 'aws',
    #      'platform_uuid' => 'i-1234abc',
    #      'role' => 'compliance',
    #      'license' => '25'
    #    }
    #  }

    params = { "user" => {}, "node" => {} }

    # User info gets pulled in from chef-marketplace-ctl register-node
    params["user"] = node["chef-marketplace"]["registration"].to_hash

    params["node"]["license"] =
      if node["chef-marketplace"]["license"]["type"] == "flexible"
        "flexible"
      else
        node["chef-marketplace"]["license"]["count"].to_s
      end
    params["node"]["platform"] = node["chef-marketplace"]["platform"]
    params["node"]["role"] = node["chef-marketplace"]["role"]
    params["node"]["platform_uuid"] =
      begin
        case node["cloud_v2"]["provider"]
        when "gce"
          node["gce"]["instance"]["id"]
        when "ec2"
          node["ec2"]["instance_id"]
        else # azure, etc..
          node["chef-marketplace"]["api_fqdn"]
        end
      rescue
        node["chef-marketplace"]["api_fqdn"]
      end

    client = Marketplace::ApiClient.new(params["user"].delete("address"))
    res = client.post("/nodes/register", params)
    raise res.message unless (200...400).cover?(res.code.to_i)
  end
end
