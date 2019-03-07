module Biscotti
  module Routes
    class Index < Biscotti::Routes::Base
      get "/" do
        send_file File.join(settings.public_folder, "index.html")
      end
    end
  end
end
