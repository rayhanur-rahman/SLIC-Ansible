module Biscotti
  module Extensions
    module JSONDSL
      module_function

      module Helpers
        def payload
          @parsed_payload ||= parse_payload
        end

        def parse_payload
          @parsed_payload =
            if request.body && request.env["CONTENT_TYPE"] =~ /json/
              JSON.parse(request.body.read)
            else
              request.body.read
            end
        end
      end
    end
  end
end
