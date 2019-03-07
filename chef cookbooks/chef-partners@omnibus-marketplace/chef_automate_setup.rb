require "rest-client"
require "json"

module Biscotti
  class ChefAutomateSetup
    attr_accessor :admin_password, :first_name, :last_name, :username, :email,
                  :password, :public_key

    def initialize(admin_password:, first_name:, last_name:, username:, email:,
                   password:, public_key:)
      @admin_password   = admin_password
      @first_name       = first_name
      @last_name        = last_name
      @username         = username
      @email            = email
      @password         = password
      @public_key       = public_key
    end

    def api
      @api ||=
        begin
          client = RestClient::Resource.new(
            "https://localhost/api/v0/e/default",
            verify_ssl: false,
            headers: { "Content-Type" => "application/json" }
          )
          payload = { username: "admin", password: admin_password }.to_json
          token = JSON.parse(client["get-token"].post(payload).body)["token"]
          client.headers["chef-delivery-token"] = token
          client.headers["chef-delivery-user"] = "admin"
          client
        end
    end

    def create_user
      api["internal-users"].post({
        name: username,
        first: first_name,
        last: last_name,
        email: email,
        ssh_pub_key: public_key,
      }.to_json)
    end

    def set_user_password
      api["internal-users/#{username}/change-password"].post({
        password: password,
      }.to_json)
    end

    def set_user_privileges
      api["authz/users/#{username}"].post({
        set: ["admin"],
      }.to_json)
    end
  end
end
