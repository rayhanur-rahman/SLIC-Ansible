#
# Cookbook:   rundeck-server
# Attributes: default
#

# Java 8 is needed for RunDeck 2.7.x, Rundeck author suggests Java 7 and below
# is now deprecated in terms of support
default['rundeck_server']['install_java'] = true
default['java']['jdk_version'] = '8'

# Version of Rundeck packages
default['rundeck_server']['packages'] = {
  'rundeck'        => '2.7.1-1.25.GA',
  'rundeck-config' => '2.7.1-1.25.GA'
}

# This depends on the package used
default['rundeck_server']['confdir'] = '/etc/rundeck'
default['rundeck_server']['basedir'] = '/var/lib/rundeck'
default['rundeck_server']['logdir']  = '/var/log/rundeck'
default['rundeck_server']['datadir'] = '/var/rundeck'

# <> Default security-role/role-name allowed to authenticate
default['rundeck_server']['rolename'] = 'user'
# see https://github.com/rundeck/rundeck/wiki/Faq#i-get-an-error-logging-in-http-error-403--reason-role for more information

# <> session timeout in the UI (in minutes)
default['rundeck_server']['session_timeout'] = 30

# <> Repository containing the rundeck package
default['rundeck_server']['repo'] = 'http://dl.bintray.com/rundeck/rundeck-rpm/'

# <> Plugin list to install. Type is { 'pluginname' => { 'url' => URL } }
default['rundeck_server']['plugins']['winrm']['url'] = 'https://github.com/rundeck-plugins/rundeck-winrm-plugin/releases/download/v1.2/rundeck-winrm-plugin-1.2.jar'

# JVM configuration
#
# Option mapping rules
# ['key'] = 'string' maps to -key=string
# ['key'] = boolean  maps to -key if boolean is true
#
# System properties (D prefix)
default['rundeck_server']['jvm']['Dloginmodule.name']                = 'RDpropertyfilelogin'
default['rundeck_server']['jvm']['Drdeck.config']                    = node['rundeck_server']['confdir']
default['rundeck_server']['jvm']['Drundeck.server.configDir']        = node['rundeck_server']['confdir']
default['rundeck_server']['jvm']['Drundeck.server.serverDir']        = node['rundeck_server']['basedir']
# Default is the directory containing the launcher jar
default['rundeck_server']['jvm']['Drdeck.base']                      = node['rundeck_server']['basedir']
# <> Address/hostname to listen on
default['rundeck_server']['jvm']['Dserver.http.host']                = '0.0.0.0'
# <> The HTTP port to use for the server
default['rundeck_server']['jvm']['Dserver.http.port']                = '4440'
# <> The HTTPS port to use or the server
default['rundeck_server']['jvm']['Dserver.https.port']               = '4443'
default['rundeck_server']['jvm']['Djava.io.tmpdir']                  = ::File.join('tmp', 'rundeck')
# <> Path to server datastore dir
default['rundeck_server']['jvm']['Dserver.datastore.path']           = ::File.join(node['rundeck_server']['basedir'], 'data')
default['rundeck_server']['jvm']['Djava.security.auth.login.config'] = ::File.join(node['rundeck_server']['confdir'], 'jaas-loginmodule.conf')
default['rundeck_server']['jvm']['Drdeck.projects']                  = ::File.join(node['rundeck_server']['datadir'], 'projects')
default['rundeck_server']['jvm']['Drdeck.runlogs']                   = ::File.join(node['rundeck_server']['basedir'], 'logs')
default['rundeck_server']['jvm']['Drundeck.config.location']         = ::File.join(node['rundeck_server']['confdir'], 'rundeck-config.properties')
# Extension options (X prefix)
default['rundeck_server']['jvm']['XX:MaxPermSize'] = '256m'
default['rundeck_server']['jvm']['Xmx1024m']       = true
default['rundeck_server']['jvm']['Xms256m']        = true
default['rundeck_server']['jvm']['server']         = true

# <> Quartz job threadCount
default['rundeck_server']['threadcount'] = 10
# see http://rundeck.org/docs/administration/tuning-rundeck.html#quartz-job-threadcount

# rundeck-config.properties configuration
default['rundeck_server']['rundeck-config.properties']['loglevel.default'] = 'INFO'
default['rundeck_server']['rundeck-config.properties']['rdeck.base']       = node['rundeck_server']['basedir']
default['rundeck_server']['rundeck-config.properties']['rss.enabled']      = false
default['rundeck_server']['rundeck-config.properties']['grails.serverURL'] = 'http://localhost:4440'
# see http://www.h2database.com/html/changelog.html (Starting with Version 1.4.177 Beta)
# Fixes implicit relative path usage
default['rundeck_server']['rundeck-config.properties']['dataSource.url']   = 'jdbc:h2:file:~/grailsh2'

# rundeck-config.framework configuration
default['rundeck_server']['rundeck-config.framework']['framework.server.name']      = 'localhost'
default['rundeck_server']['rundeck-config.framework']['framework.server.hostname']  = 'localhost'
default['rundeck_server']['rundeck-config.framework']['framework.server.port']      = '4440'
default['rundeck_server']['rundeck-config.framework']['framework.server.url']       = 'http://localhost:4440'
default['rundeck_server']['rundeck-config.framework']['framework.server.username']  = 'admin'
default['rundeck_server']['rundeck-config.framework']['framework.server.password']  = 'admin'
default['rundeck_server']['rundeck-config.framework']['rdeck.base']                 = '/var/lib/rundeck'
default['rundeck_server']['rundeck-config.framework']['framework.projects.dir']     = '/var/rundeck/projects'
default['rundeck_server']['rundeck-config.framework']['framework.etc.dir']          = '/etc/rundeck'
default['rundeck_server']['rundeck-config.framework']['framework.var.dir']          = '/var/lib/rundeck/var'
default['rundeck_server']['rundeck-config.framework']['framework.tmp.dir']          = '/var/lib/rundeck/var/tmp'
default['rundeck_server']['rundeck-config.framework']['framework.logs.dir']         = '/var/lib/rundeck/logs'
default['rundeck_server']['rundeck-config.framework']['framework.libext.dir']       = '/var/lib/rundeck/libext'
default['rundeck_server']['rundeck-config.framework']['framework.ssh.keypath']      = '/var/lib/rundeck/.ssh/id_rsa'
default['rundeck_server']['rundeck-config.framework']['framework.ssh.user']         = 'rundeck'
default['rundeck_server']['rundeck-config.framework']['framework.ssh.timeout']      = 0

# realm.properties users
default['rundeck_server']['realm.properties']['admin'] = 'admin,user,admin,architect,deploy,build'

# See: https://github.com/rundeck/rundeck-cli/blob/master/docs/configuration.md
default['rundeck_server']['cli']['config'] = {
  RD_URL: 'http://localhost:4440'
}
default['rundeck_server']['cli']['version'] = '1.0.5-1'

# <> The JAAS login configuration file with one entry and multiple modules may be generated from this attribute.
default['rundeck_server']['jaas'] = [{
  module:  'org.eclipse.jetty.jaas.spi.PropertyFileLoginModule',
  flag:    'required',
  options: {
    debug: 'true',
    file:  '/etc/rundeck/realm.properties'
  }
}]
# see http://docs.oracle.com/javase/8/docs/technotes/guides/security/jgss/tutorials/LoginConfigFile.html

# <> The admin ACL policy in YAML is generated from this attribute.
default['rundeck_server']['aclpolicy']['admin'] = [{
  description: 'Admin, all access.',
  context: {
    project: '.*'
  },
  for: {
    resource: [{ allow: '*' }],
    adhoc:    [{ allow: '*' }],
    job:      [{ allow: '*' }],
    node:     [{ allow: '*' }]
  },
  by: {
    group:    ['admin']
  }
}, {
  description: 'Admin, all access.',
  context: {
    application: 'rundeck'
  },
  for: {
    resource: [{ allow: '*' }],
    project:  [{ allow: '*' }],
    storage:  [{ allow: '*' }]
  },
  by: {
    group:    ['admin']
  }
}]
# Check out the docs at: http://rundeck.org/docs/man5/aclpolicy.html
