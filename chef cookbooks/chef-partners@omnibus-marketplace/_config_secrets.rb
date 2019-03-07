## SECRETS CONFIGURATION ##
#
# This file is for managing secrets that need to be regenerated in a chef-marketplace
# install.
#

# read the existing secrets from the secrets file on disk and default
# to an empty hash if that file does not exist
secrets_file = "/etc/chef-marketplace/chef-marketplace-secrets.json"
secrets_from_file = if ::File.exist?(secrets_file)
                      Chef::JSONCompat.from_json(::File.read(secrets_file))
                    else
                      {}
                    end

## ADD NEW SECRETS HERE ##
# To add a new secret to chef-markteplace, simply add it into the hash here. It will
# be randomly generated to your specification with the SecureRandom class and
# automatically persisted to the secrets file upon a reconfigure.
#
default_secrets = {
  "biscotti" => {
    "token" => SecureRandom.hex(50)
  },
  "automate" => {
    "postgresql" => {
      "superuser_password" => SecureRandom.hex(50)
    },
    "data_collector" => {
      "token" => SecureRandom.hex(50)
    },
    "passwords" => {
      "chef_user" => SecureRandom.base64(12),
      "admin_user" => SecureRandom.base64(12),
      "builder_user" => SecureRandom.base64(12)
    }
  }
}

# Hash#merge will override any values in the original hash with values that
# come from the input, so all values coming from the file on disk will be
# overwrite the random data
new_secrets = Chef::Mixin::DeepMerge.deep_merge(secrets_from_file, default_secrets)

file secrets_file do
  content Chef::JSONCompat.to_json_pretty(new_secrets)
  sensitive true
  action :create
end

node.consume_attributes("chef-marketplace" => new_secrets)
