#
# Chef Client Config File
#
# Will be overwritten
#

log_level        :info
log_location     STDOUT
file_store_path  "/var/chef/file_store"
file_cache_path  "/var/chef/cache"
ssl_verify_mode  :verify_none
chef_server_url  "http://127.0.0.1/organizations/local-test-org" 
registration_url "http://127.0.0.1/organizations/local-test-org" 
openid_url       "http://127.0.0.1/organizations/local-test-org" 
template_url     "http://127.0.0.1/organizations/local-test-org" 
remotefile_url   "http://127.0.0.1/organizations/local-test-org" 
search_url       "http://127.0.0.1/organizations/local-test-org" 
role_url         "http://127.0.0.1/organizations/local-test-org" 
client_url       "http://127.0.0.1/organizations/local-test-org" 
validation_client_name "local-test-org-validator"
validation_key     "/tmp/local-test-org-validator.pem"



