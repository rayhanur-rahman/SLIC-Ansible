module Biscotti
  module Extensions
    module AuthorizeDSL
      module_function

      module Helpers
        include Biscotti::Extensions::JSONDSL::Helpers

        def valid_uuid?(uuid)
          return true unless Biscotti::App.settings.biscotti["uuid"]

          Biscotti::App.settings.biscotti["uuid"] == uuid
        end

        def valid_token?(token)
          hashed_token == token
        end

        def handle_authorize!
          halt(400) unless payload.keys.length == 1 && payload["uuid"]
          halt(401) unless valid_uuid?(payload["uuid"])
        end

        def authorize!
          halt(400) unless payload.key?("token")
          halt(401) unless valid_token?(payload["token"])
        end

        def hashed_token
          Biscotti::Bakery.new(
            Biscotti::App.settings.biscotti["token"],
            Biscotti::App.settings.biscotti["uuid"]
          ).cookie[:value]
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
