require 'seth/platform'

class Seth
  module SethFS
    def self.windows?
      Seth::Platform.windows?
    end
  end
end
