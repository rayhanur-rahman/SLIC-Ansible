require "zip"
require "uri"

module Biscotti
  class StarterKit
    attr_accessor :private_key, :validator_key, :admin_password, :builder_password,
                  :organization, :username, :last_name, :first_name, :email, :password,
                  :platform, :platform_uuid, :frontend_url, :hostname

    def initialize(admin_password:, builder_password:, organization:, username:,
                   last_name:, first_name:, email:, password:, validator_key:,
                   private_key:, frontend_url:)
      @admin_password   = admin_password
      @builder_password = builder_password
      @organization     = organization
      @username         = username
      @email            = email
      @password         = password
      @private_key      = private_key
      @validator_key    = validator_key
      @frontend_url     = frontend_url
      @hostname         = URI(frontend_url).host
    end

    def zip
      @zip ||= begin
        Zip::OutputStream.write_buffer do |zip|
          zip.put_next_entry(validator_key_filename)
          zip.write(validator_key)

          zip.put_next_entry(pivotal_key_filename)
          zip.write(pivotal_key)

          if private_key
            zip.put_next_entry(user_private_key_filename)
            zip.write(private_key)
          end

          zip.put_next_entry(knife_config_filename)
          zip.write(knife_config)

          zip.put_next_entry(pivotal_knife_config_filename)
          zip.write(pivotal_knife_config)

          zip.put_next_entry(automate_credentials_filename)
          zip.write(automate_credentials)

          zip.put_next_entry(trusted_cert_filename)
          zip.write(trusted_cert)
        end.string
      end
    end

    def chef_repo_dir
      "chef-repo"
    end

    def chef_dir
      File.join(chef_repo_dir, ".chef")
    end

    def trusted_certs_dir
      File.join(chef_dir, "trusted_certs")
    end

    def filename
      "starter_kit.zip"
    end

    def knife_config_filename
      File.join(chef_dir, "knife.rb")
    end

    def pivotal_knife_config_filename
      File.join(chef_dir, "pivotal.rb")
    end

    def validator_key_filename
      File.join(chef_dir, "#{organization}-validator.pem")
    end

    def pivotal_key_filename
      File.join(chef_dir, "pivotal.pem")
    end

    def user_private_key_filename
      File.join(chef_dir, "#{username}.pem")
    end

    def automate_credentials_filename
      "chef-automate-credentials.txt"
    end

    def trusted_cert_filename
      File.join(trusted_certs_dir, "#{hostname}.crt")
    end

    def knife_config
      <<-EOS.gsub(/^\s+/, "")
        current_dir = ::File.dirname(__FILE__)
        log_level                :info
        log_location             $stdout
        node_name                "#{username}"
        client_key               ::File.join(current_dir, "#{username}.pem")
        validation_client_name   "#{organization}-validator"
        validation_key           ::File.join(current_dir, "#{organization}-validator.pem")
        chef_server_url          "#{frontend_url}/organizations/#{organization}"
        cookbook_path            [::File.join(current_dir, "../cookbooks")]
      EOS
    end

    def pivotal_knife_config
      <<-EOS.gsub(/^\s+/, "")
        node_name        "pivotal"
        chef_server_url  "#{frontend_url}"
        chef_server_root "#{frontend_url}"
        client_key       ::File.join(::File.dirname(__FILE__), "pivotal.pem")
      EOS
    end

    def pivotal_key
      File.read("/etc/opscode/pivotal.pem")
    end

    def trusted_cert
      File.read("/var/opt/delivery/nginx/ca/#{hostname}.crt")
    end

    def automate_credentials
      <<-EOS.gsub(/^\s+/, "")
        Admin username: admin
        Admin password: #{admin_password}

        Builder username: builder
        Builder password: #{builder_password}

        User username: #{username}
        User password: #{password}
      EOS
    end
  end
end
