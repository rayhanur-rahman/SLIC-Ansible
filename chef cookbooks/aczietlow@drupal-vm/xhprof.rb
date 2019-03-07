#
# Cookbook Name:: lamp
# Recipe:: default
#
# Copyright 2013, Mediacurrent
#
# All rights reserved - Do Not Redistribute
#

php_pear "xhprof" do
  preferred_state "beta"
  action :install
end

package "graphviz" do
  action :install
end

link "/var/www/xhprof" do
  to "/usr/share/php/xhprof_html"
end

# Create virtual host and enable site.
web_app "xhprof.#{node[:domain]}" do
  cookbook "apache2"
  allow_override "All"
  docroot "/var/www/xhprof"
  server_aliases []
  server_name "xhprof.#{node[:domain]}"
end
