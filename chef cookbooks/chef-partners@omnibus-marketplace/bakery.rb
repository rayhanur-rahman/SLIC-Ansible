require "digest"
require "time"

module Biscotti
  class Bakery
    attr_reader :token, :uuid, :name, :digest

    def initialize(token, uuid)
      @name = "ChefMarketplaceAuth"
      @token = token
      @uuid = uuid
    end

    def cookie
      {
        value: Digest::SHA2.hexdigest(token + uuid),
        domain: "",
        path: "/",
        expires: Time.now + (3600 * 24 * 31),
      }
    end
  end
end
