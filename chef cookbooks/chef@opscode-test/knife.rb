current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "opscode-ci"
client_key               "#{current_dir}/opscode-ci.pem"
validation_client_name   "opscode-ci-org-validator"
validation_key           "#{current_dir}/opscode-ci-org-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/opscode-ci-org"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
