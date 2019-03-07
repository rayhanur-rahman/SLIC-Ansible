#
# Cookbook Name:: utils
# Attributes:: varnish
#
# Copyright 2013, Mediacurrent
#
# All rights reserved - Do Not Redistribute

include_attribute "varnish"

node['varnish']['version'] = '3.0'
node['varnish']['vcl_source'] = 'varnish-3.erb'
node['varnish']['vcl_cookbook'] = "utils::varnish"

node['varnish']['backend_host'] = '127.0.0.1'
node['varnish']['backend_port'] = 80
node['varnish']['secret-non_secure'] = '44cc6ff6-75b1-4187-9637-045ccf41653b'
