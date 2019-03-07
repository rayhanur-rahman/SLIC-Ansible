maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Configures chef-solr from Chef Repo and starts service"
long_description  <<-EOH
Runs chef-solr and chef-expander from Chef Repo.
EOH
version           "0.7.2"
recipe            "chef-solr", "Configures chef-solr from Chef Repo and starts service"
depends           "opscode-base"
depends           "opscode-github"
depends           "runit"
depends           "capistrano"
depends           "java"
