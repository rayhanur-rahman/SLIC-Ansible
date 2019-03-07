#
# Cookbook Name:: default-mcdev
# Attributes:: default
#
# Copyright 2013, Mediacurrent
#
# All rights reserved - Do Not Redistribute

# You may specify attribute overrides here. However, if there is only one or two
# attributes that need to be changed you may set them in the attribute overrides
# JSON array in the Vagrantfile.

# LAMP overrides.
#override['lamp']['php']['memory_limit'] = '128M'

# ApacheSolr overrides.
#override['jetty']['port'] = 8983
#override['solr']['version'] = '3.6.2'
#override['utils']['solr']['drupal_module_path'] = "#{node[:docroot]}/sites/all/modules/apachesolr"
