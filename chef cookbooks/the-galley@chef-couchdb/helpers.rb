require 'chef'
require 'uri'
require 'net/http'

module Couchdb
  module Helpers
    @@default_options = {secure: false, port: 5984, verify_ssl: false, body: ''}

    ## Options can be body, port, secure, and verify_ssl
    def query_couchdb(urn, verb, host = '127.0.0.1', options = @@default_options)
      secure = options[:secure] || @@default_options[:secure]
      body = options[:body] || @@default_options[:body]

      ## Set scheme
      scheme = secure ? 'https' : 'http'
      ## build uri
      url = "#{scheme}://#{host}"
      uri = URI.join(url, urn)
      Chef::Log.debug("query_couchdb built uri: #{uri}")

      http = Net::HTTP.new(uri.host, options[:port])
      http.use_ssl = secure
      unless options[:verify_ssl] || @@default_options[:verify_ssl]
        Chef::Log.debug('verify_ssl is false setting verify to none')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if body.empty?
        retry_request(http, verb.upcase, uri.request_uri)
      else
        if body.is_a? Hash
          headers = { 'Content-Type' => 'application/json' }
          body = JSON.generate(body)
        else
          body = "\"#{body}\""
        end
        retry_request(http, verb.upcase, uri.request_uri, body, headers)
      end
    end

    ## Wraps the http send_request in a retry loop
    def retry_request(http, *args)
      5.times do
        begin
          return http.send(:send_request, *args)
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          Chef::Log.debug('couchdb connection failed')
        end
        sleep 1
      end
      Chef::Log.debug('failed to connect to couchdb after 5 tries ... failing chef run')
      fail 'unable to connect to couchdb'
    end

    ## Wraps query_couchdb and passes get verb
    def couchdb_get(urn, host = '127.0.0.1', options = @@default_options)
      query_couchdb(urn, 'GET', host, options)
    end

    ## Wraps query_couchdb and passes put verb
    def couchdb_put(urn, host = '127.0.0.1', options = @@default_options)
      query_couchdb(urn, 'PUT', host, options)
    end

    ## Wraps query_couchdb and passes delete verb
    def couchdb_delete(urn, host = '127.0.0.1', options = @@default_options)
      query_couchdb(urn, 'DELETE', host, options)
    end

    ## Wraps query_couchdb and passes post verb
    def couchdb_post(urn, host = '127.0.0.1', options = @@default_options)
      query_couchdb(urn, 'POST', host, options)
    end
  end
end
