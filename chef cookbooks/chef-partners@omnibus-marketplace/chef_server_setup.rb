require "chef/server_api"

module Biscotti
  class ChefServerSetup
    attr_accessor :organization, :username, :last_name, :first_name, :email,
                  :password, :public_key

    def initialize(organization:, username:, last_name:, first_name:, email:,
                   password:, public_key:)

      Chef::Config[:ssl_verify_mode] = :verify_none

      @organization     = organization
      @username         = username
      @last_name        = last_name
      @first_name       = first_name
      @email            = email
      @password         = password
      @public_key       = public_key
    end

    def api
      @api ||= Chef::ServerAPI.new(
        "https://localhost/organizations/#{organization}",
        client_name: "pivotal",
        signing_key_filename: "/etc/opscode/pivotal.pem",
        api_version: "1"
      )
    end

    def root_api
      @root_api ||= Chef::ServerAPI.new(
        "https://localhost",
        client_name: "pivotal",
        signing_key_filename: "/etc/opscode/pivotal.pem",
        api_version: "1"
      )
    end

    def create_org
      root_api.post(
        "organizations",
        { name: organization,
          full_name: organization,
        }
      )["private_key"]
    end

    def create_user
      root_api.post(
        "users",
        { username: username,
          first_name: first_name,
          last_name: last_name,
          display_name: display_name,
          email: email,
          password: password,
          public_key: public_key,
        }
      )
    end

    def associate_user
      assoc_id = api.post(
        "association_requests",
        { user: username }
      )["uri"].split("/").last

      root_api.put(
        "users/#{username}/association_requests/#{assoc_id}",
        { response: "accept" }
      )
    end

    def display_name
      "#{first_name} #{last_name}"
    end
  end
end
