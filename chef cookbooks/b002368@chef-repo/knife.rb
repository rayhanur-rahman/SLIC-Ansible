# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

cookbook_copyright 		"Macys"
cookbook_license 		"apachev2"
cookbook_email 			"mike.hsieh@macys.com"
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
<<<<<<< HEAD
=======
ssl_verify_mode :verify_none
>>>>>>> deca7c98ab6173abb0ac3d00ca450b24d1ee113c
node_name                "mikehsieh97"
client_key               "#{current_dir}/mikehsieh97.pem"
#validation_client_name   "/c/Users/b002368/Documents/MikeH_Owns/CHEF/chef-repo/cdinc-validator"
#validation_key           "/c/Users/b002368/Documents/MikeH_Owns/CHEF/chef-repo/cdinc-validator.pem"
chef_server_url          "https://api.chef.io/organizations/cdinc"
cache_type               'BasicFile'
cache_options(:path => "#{ENV['HOME']}/.chef/checksums")
cookbook_path            ["#{current_dir}/../cookbooks"]

