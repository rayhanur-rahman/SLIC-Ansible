name 'enterprise'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs common libraries and resources for Chef server and add-ons'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.14.2'

depends 'runit', '= 4.1.1'

source_url 'https://github.com/chef-cookbooks/enterprise'
issues_url 'https://github.com/chef-cookbooks/enterprise/issues'

chef_version '>= 12.7' if respond_to?(:chef_version)

%w(redhat oracle centos scientific fedora amazon debian ubuntu).each do |os|
  supports os
end
