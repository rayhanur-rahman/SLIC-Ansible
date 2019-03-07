name              "config-driven-helper"
maintainer        "Inviqa"
maintainer_email  "athompson@inviqa.com"
issues_url        "https://github.com/inviqa/chef-config-driven-helper/issues"
source_url        "https://github.com/inviqa/chef-config-driven-helper"
license           "Apache 2.0"
description       "enable driving cookbooks that are not normally config driven to be so"
version           "3.2.0"

depends "apache2", ">= 1.8"
depends 'iptables-ng', '>= 2.2'
depends "mysql", "~> 4.0"
depends 'nginx', '< 2.4.4'
depends "database", "~> 2.0.0"
depends "build-essential", "~> 1.4"

%w{ debian ubuntu centos redhat fedora scientific amazon windows }.each do |os|
  supports os
end

recipe "apache-sites", "Propagates sites from node config to web_app"
recipe "nginx-sites", "Propagates sites from node config to nginx site"
recipe "mysql-users", "Creates mysql users using the database cookbook"
recipe "mysql-ruby", "Installs MySQL ruby gem in chef ruby"
recipe "mysql-databases", "Creates mysql databases using the database cookbook"
recipe "packages-additional", "Installs packages"
recipe "services", "Enables service actions"
