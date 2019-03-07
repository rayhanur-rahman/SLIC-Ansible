name             'rundeck-server'
maintainer       'Criteo'
maintainer_email 'use_github_issues@criteo.com'
license          'Apache-2.0'
description      'Installs rundeck and configure as needed'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.7.3'
supports         'centos'

depends          'yum'
depends          'java'

source_url 'https://github.com/criteo-cookbooks/rundeck-server' if defined?(source_url)
issues_url 'https://github.com/criteo-cookbooks/rundeck-server/issues' if defined?(issues_url)

chef_version '>= 12.18.31' if defined?(chef_version)
