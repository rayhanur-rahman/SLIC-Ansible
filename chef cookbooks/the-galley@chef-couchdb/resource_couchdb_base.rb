class Chef
  class Resource
    class CouchdbBase < Chef::Resource
      def initialize(name, run_context=nil)
        super
      end

      def host(arg=nil)
        set_or_return(:host,
                      arg,
                      kind_of: String,
                      default: '127.0.0.1')
      end

      def port(arg=nil)
        set_or_return(:port,
                      arg,
                      kind_of: [String, Integer],
                      default: 5984)
      end

      def admin(arg=nil)
        set_or_return(:admin,
                      arg,
                      kind_of: String)
      end

      def password(arg=nil)
        set_or_return(:password,
                      arg,
                      kind_of: String)
      end

      def secure(arg=nil)
        set_or_return(:secure,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: false)
      end

      def verify_ssl(arg=nil)
        set_or_return(:verify_ssl,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: true)
      end
    end
  end
end
