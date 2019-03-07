# Imported From Rundeck 2.5.3-1.10.GA
#
####################################################################################################
#
#  Log Levels
#
####################################################################################################

# Enable logging for everything. Rarely useful
default['rundeck_server']['log4j.properties']['log4j.rootLogger'] = 'warn, stdout, server-logger'

default['rundeck_server']['log4j.properties']['log4j.com.dtolabs.rundeck.core'] = 'INFO, cmd-logger'

# log4j.logger.org.codehaus.groovy.grails.plugins.quartz'] = 'debug,stdout'
# log4j.additivity.org.codehaus.groovy.grails.plugins.quartz'] = 'false'

# Enable audit logging
default['rundeck_server']['log4j.properties']['log4j.logger.com.dtolabs.rundeck.core.authorization'] = 'info, audit'
default['rundeck_server']['log4j.properties']['log4j.additivity.com.dtolabs.rundeck.core.authorization'] = 'false'

# Enable options remote URL logging
default['rundeck_server']['log4j.properties']['log4j.logger.com.dtolabs.rundeck.remoteservice.http.options'] = 'INFO, options'
default['rundeck_server']['log4j.properties']['log4j.additivity.com.dtolabs.rundeck.remoteservice.http.options'] = 'false'

# Enable Job changes logging
default['rundeck_server']['log4j.properties']['log4j.logger.com.dtolabs.rundeck.data.jobs.changes'] = 'INFO, jobchanges'
default['rundeck_server']['log4j.properties']['log4j.additivity.com.dtolabs.rundeck.data.jobs.changes'] = 'false'

# Enable Execution event logging
default['rundeck_server']['log4j.properties']['log4j.logger.org.rundeck.execution.status'] = 'INFO, execevents'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.rundeck.execution.status'] = 'false'

# Enable API request logging
default['rundeck_server']['log4j.properties']['log4j.logger.org.rundeck.api.requests'] = 'INFO,apirequests'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.rundeck.api.requests'] = 'false'

# Enable Web access logging
default['rundeck_server']['log4j.properties']['log4j.logger.org.rundeck.web.requests'] = 'INFO,access'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.rundeck.web.requests'] = 'false'

# Enable Storage logging
default['rundeck_server']['log4j.properties']['log4j.logger.org.rundeck.storage.events'] = 'INFO,storage'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.rundeck.storage.events'] = 'false'

# Enable this logger to log Hibernate output
# handy to see its database interaction activity
# log4j.logger.org.hibernate'] = 'debug,stdout'
# log4j.additivity.org.hibernate'] = 'false'

# Enable this logger to see what Spring does, occasionally useful
# log4j.logger.org.springframework'] = 'info,stdout '
# log4j.additivity.org.springframework'] = 'false'

# This logger covers all of Grails' internals
# Enable to see whats going on underneath.
default['rundeck_server']['log4j.properties']['log4j.logger.org.codehaus.groovy.grails'] = 'warn,stdout, server-logger'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.codehaus.groovy.grails'] = 'false'

# This logger is useful if you just want to see what Grails
# configures with Spring at runtime. Setting to debug will show
# each bean that is configured
default['rundeck_server']['log4j.properties']['log4j.logger.org.codehaus.groovy.grails.commons.spring'] = 'warn,stdout, server-logger'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.codehaus.groovy.grails.commons.spring'] = 'false  '

# Interesting Logger to see what some of the Grails factory beans are doing
default['rundeck_server']['log4j.properties']['log4j.logger.org.codehaus.groovy.grails.beans.factory'] = 'warn,stdout, server-logger'
default['rundeck_server']['log4j.properties']['log4j.additivity.org.codehaus.groovy.grails.beans.factory'] = 'false'

# This logger is for Grails' public APIs within the grails. package
default['rundeck_server']['log4j.properties']['log4j.logger.grails'] = 'info,stdout, server-logger'
default['rundeck_server']['log4j.properties']['log4j.additivity.grails'] = 'false        '

####################################################################################################
#
#  Appender Configuration (unlikely a change needs to be made, unless you have unique logging reqs.)
#
####################################################################################################

#
# stdout - ConsoleAppender
#
default['rundeck_server']['log4j.properties']['log4j.appender.stdout'] = 'org.apache.log4j.ConsoleAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.stdout.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.stdout.layout.ConversionPattern'] = '%-5p %c{1}: %m%n'

#
# cmd-logger - DailyRollingFileAppender
#
# Output of the RunDeck command line utilities
#
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger.file'] = ::File.join(node['rundeck_server']['logdir'], 'command.log')
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger.datePattern'] = "'.'yyyy-MM-dd"
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.cmd-logger.layout.ConversionPattern'] = '%d{ISO8601} [%t] %-5p %c - %m%n'

#
# server-logger - DailyRollingFileAppender
#
# Captures all output from the rundeckd server.
#
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.log')
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger.datePattern'] = "'.'yyyy-MM-dd"
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.server-logger.layout.ConversionPattern'] = '%d{ISO8601} [%t] %-5p %c - %m%n'

#
# audit
#
# Captures all audit events.
#
default['rundeck_server']['log4j.properties']['log4j.appender.audit'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.audit.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.audit.log')
default['rundeck_server']['log4j.properties']['log4j.appender.audit.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.audit.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.audit.layout.ConversionPattern'] = '%d{ISO8601} - %m%n'

#
# options log
#
# Logs remote HTTP requests for Options JSON data
#
default['rundeck_server']['log4j.properties']['log4j.appender.options'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.options.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.options.log')
default['rundeck_server']['log4j.properties']['log4j.appender.options.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.options.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.options.layout.ConversionPattern'] = '[%d{ISO8601}] %X{httpStatusCode} %X{contentLength}B %X{durationTime}ms %X{lastModifiedDateTime} [%X{jobName}] %X{url} %X{contentSHA1}%n'

#
# storage log
#
# Logs events for Rundeck storage layer
#
default['rundeck_server']['log4j.properties']['log4j.appender.storage'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.storage.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.storage.log')
default['rundeck_server']['log4j.properties']['log4j.appender.storage.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.storage.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.storage.layout.ConversionPattern'] = '[%d{ISO8601}] %X{action} %X{type} %X{path} %X{status} %X{metadata}%n'

#
# job changes log
#
# Logs all Job definition changes
#
default['rundeck_server']['log4j.properties']['log4j.appender.jobchanges'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.jobchanges.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.jobs.log')
default['rundeck_server']['log4j.properties']['log4j.appender.jobchanges.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.jobchanges.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.jobchanges.layout.ConversionPattern'] = '[%d{ISO8601}] %X{user} %X{change} [%X{id}] %X{project} "%X{groupPath}/%X{jobName}" (%X{method})%n'

#
# executions log
#
# Logs all execution events (start,finish,delete)
#
default['rundeck_server']['log4j.properties']['log4j.appender.execevents'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.execevents.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.executions.log')
default['rundeck_server']['log4j.properties']['log4j.appender.execevents.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.execevents.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.execevents.layout.ConversionPattern'] = '[%d{ISO8601}] %X{eventUser} %X{event} [%X{id}:%X{state}] %X{project} %X{user}/%X{abortedby} "%X{groupPath}/%X{jobName}"[%X{uuid}]%n'

#
# api request log
#
# Logs all API requests
#
default['rundeck_server']['log4j.properties']['log4j.appender.apirequests'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.apirequests.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.api.log')
default['rundeck_server']['log4j.properties']['log4j.appender.apirequests.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.apirequests.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.apirequests.layout.ConversionPattern'] = '[%d{ISO8601}] %X{remoteHost} %X{secure} %X{remoteUser} %X{authToken} %X{duration} %X{project} "%X{method} %X{uri}" (%X{userAgent})%n'

#
# Web access log
#
# Logs all Web requests
#
default['rundeck_server']['log4j.properties']['log4j.appender.access'] = 'org.apache.log4j.DailyRollingFileAppender'
default['rundeck_server']['log4j.properties']['log4j.appender.access.file'] = ::File.join(node['rundeck_server']['logdir'], 'rundeck.access.log')
default['rundeck_server']['log4j.properties']['log4j.appender.access.append'] = 'true'
default['rundeck_server']['log4j.properties']['log4j.appender.access.layout'] = 'org.apache.log4j.PatternLayout'
default['rundeck_server']['log4j.properties']['log4j.appender.access.layout.ConversionPattern'] = '[%d{ISO8601}] "%X{method} %X{uri}" %X{remoteHost} %X{secure} %X{remoteUser} %X{authToken} %X{duration} %X{project} [%X{contentType}] (%X{userAgent})%n'
