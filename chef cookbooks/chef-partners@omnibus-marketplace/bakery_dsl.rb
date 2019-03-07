module Biscotti
  module Extensions
    module BakeryDSL
      module_function

      module Helpers
        def bake_cookie
          bakery = Biscotti::Bakery.new(Biscotti::App.settings.biscotti["token"], params["uuid"])
          response.set_cookie("ChefMarketplaceAuth", bakery.cookie)
        end

        def valid_uuid?
          Biscotti::App.settings.biscotti["uuid"] &&
            params["uuid"] &&
            Biscotti::App.settings.biscotti["uuid"] == params["uuid"]
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
