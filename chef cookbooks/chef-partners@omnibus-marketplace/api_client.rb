require "net/http"
require "uri"
require "ostruct"
require "json"
require "openssl"

class Marketplace
  class ApiClient
    attr_reader :connection

    def initialize(endpoint = "https://marketplace.chef.io")
      uri = URI.parse(endpoint)
      @connection = Net::HTTP.new(uri.host, uri.port)
      @connection.use_ssl = uri.scheme == "https"
    end

    def get(path, params)
      request_json(:get, path, params)
    end

    def post(path, params)
      request_json(:post, path, params)
    end

    def put(path, params)
      request_json(:put, path, params)
    end

    def delete(path, params)
      request_json(:delete, path, params)
    end

    private

    def request_json(method, path, params)
      response = request(method, path, params)
      body = JSON.parse(response.body)

      OpenStruct.new(code: response.code, body: body, message: response.message)
    rescue JSON::ParserError
      response
    end

    def request(method, path, params = {})
      if method.to_sym == :get
        path = "#{path}?#{URI.encode_www_form(params)}"
        request = Net::HTTP.const_get(method.capitalize.to_sym).new(path)
      else
        request = Net::HTTP.const_get(method.capitalize.to_sym).new(path)
        request.body = params.to_json
        request["Content-Type"] = "application/vnd+json"
      end

      connection.request(request)
    end
  end
end
