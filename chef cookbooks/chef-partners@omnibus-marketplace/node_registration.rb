require "rest-client"

module Biscotti
  class NodeRegistration
    attr_accessor :license, :platform, :platform_uuid, :role, :first_name,
                  :last_name, :email, :organization

    def initialize(license:, platform:, platform_uuid:, role:, first_name:,
                   last_name:, email:, organization:)

      @license       = license
      @platform      = platform
      @platform_uuid = platform_uuid
      @role          = role
      @first_name    = first_name
      @last_name     = last_name
      @email         = email
      @organization  = organization
    end

    def api
      @api ||= RestClient::Resource.new(
        "https://marketplace.chef.io",
        verify_ssl: false,
        headers: { "Content-Type" => "application/vnd+json" }
      )
    end

    def register
      api["/nodes/register"].post({
        "user" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email,
          "organization" => organization,
        },
        "node" => {
          "platform" => platform,
          "platform_uuid" => platform_uuid,
          "role" => role,
          "license" => license,
        },
      }.to_json)
    end
  end
end
