require 'seth/ceth'

class Seth
  class ceth
    class Raw < Seth::ceth
      banner "ceth raw REQUEST_PATH"

      deps do
        require 'seth/json_compat'
        require 'seth/config'
        require 'seth/http'
        require 'seth/http/authenticator'
        require 'seth/http/cookie_manager'
        require 'seth/http/decompressor'
        require 'seth/http/json_output'
      end

      option :method,
        :long => '--method METHOD',
        :short => '-m METHOD',
        :default => "GET",
        :description => "Request method (GET, POST, PUT or DELETE).  Default: GET"

      option :pretty,
        :long => '--[no-]pretty',
        :boolean => true,
        :default => true,
        :description => "Pretty-print JSON output.  Default: true"

      option :input,
        :long => '--input FILE',
        :short => '-i FILE',
        :description => "Name of file to use for PUT or POST"

      class RawInputServerAPI < Seth::HTTP
        def initialize(options = {})
          options[:client_name] ||= Seth::Config[:node_name]
          options[:signing_key_filename] ||= Seth::Config[:client_key]
          super(Seth::Config[:seth_server_url], options)
        end
        use Seth::HTTP::JSONOutput
        use Seth::HTTP::CookieManager
        use Seth::HTTP::Decompressor
        use Seth::HTTP::Authenticator
        use Seth::HTTP::RemoteRequestID
      end

      def run
        if name_args.length == 0
          show_usage
          ui.fatal("You must provide the path you want to hit on the server")
          exit(1)
        elsif name_args.length > 1
          show_usage
          ui.fatal("Only one path accepted for ceth raw")
          exit(1)
        end

        path = name_args[0]
        data = false
        if config[:input]
          data = IO.read(config[:input])
        end
        begin
          method = config[:method].to_sym

          if config[:pretty]
            seth_rest = RawInputServerAPI.new
            result = seth_rest.request(method, name_args[0], {'Content-Type' => 'application/json'}, data)
            unless result.is_a?(String)
              result = Seth::JSONCompat.to_json_pretty(result)
            end
          else
            seth_rest = RawInputServerAPI.new(:raw_output => true)
            result = seth_rest.request(method, name_args[0], {'Content-Type' => 'application/json'}, data)
          end
          output result
        rescue Timeout::Error => e
          ui.error "Server timeout"
          exit 1
        rescue Net::HTTPServerException => e
          ui.error "Server responded with error #{e.response.code} \"#{e.response.message}\""
          ui.error "Error Body: #{e.response.body}" if e.response.body && e.response.body != ''
          exit 1
        end
      end

    end # class Raw
  end
end

