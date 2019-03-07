name 'zabbix-server'
maintainer 'Bill Warner'
maintainer_email 'bill.warner@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures Zabbix Agent/Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.9.0'

supports 'ubuntu', '>= 14.04'

depends 'database', '>= 1.3.0'
depends 'mysql', '>= 1.3.0'
depends 'postgresql'
depends 'ufw',  '>= 0.6.1'
depends 'apt'
depends 'yum'
depends 'yum-epel'
depends 'oracle-instantclient'
depends 'java'
