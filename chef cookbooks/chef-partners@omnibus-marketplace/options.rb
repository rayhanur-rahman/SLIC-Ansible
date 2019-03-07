require "ostruct"
require "highline/import"
require "marketplace/helpers"

class Marketplace
  class Options
    include Marketplace::Helpers

    attr_accessor :options

    #
    # @param [OpenStruct] options
    #
    def initialize(options, ui = HighLine.new)
      @options = options
      @ui = ui
    end

    def validate
      required_options.each do |opt|
        next if options.send(opt)
        options[opt] =
          case opt
          when "password"
            ui.ask("<%= @key %>: ") do |q|
              q.echo = "*"
              q.validate = ->(p) { p.length >= 6 }
              q.verify_match = true
              q.gather = {
                "Please enter a password" => "",
                "Please enter it again for verification" => ""
              }
              q.responses[:not_valid] = "Password must be at least 6 characters"
            end
          when "organization"
            ui.ask("Please enter the name of your Organization (e.g. Chef):", ->(org) { normalize_option(org) }) do |q|
              q.validate = ->(o) { o =~ /[a-z0-9\-_]+/ && o.length >= 1 && o.length <= 255 }
              q.responses[:not_valid] = "The Organization name must begin with a lower-case letter or digit, may only contain lower-case letters, digits, hyphens, and underscores, and must be between 1 and 255 characters.  Please enter a valid Organization name"
            end
          when "email"
            ui.ask("Please enter your email:", ->(org) { normalize_email(org) }) do |q|
              q.validate = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
              q.responses[:not_valid] = "Your entry was not a valid email address"
            end
          else
            ui.ask("Please enter your #{opt.tr('_', ' ')}:", ->(org) { normalize_option(org) }) do |q|
              q.validate = ->(o) { o =~ /[a-z0-9\-_]+/ && o.length >= 1 && o.length <= 255 }
            end
          end
      end
    end

    # Forward everything to the options OpenStruct first
    def method_missing(meth, *args, &block)
      options.respond_to?(meth) ? options.send(meth, *args, &block) : super
    end

    private

    def required_options
      case options.role
      when "server", "aio", 'compliance'
        %w(first_name last_name username email organization password).freeze
      when "analytics"
        []
      end
    end

    attr_accessor :ui
  end
end
