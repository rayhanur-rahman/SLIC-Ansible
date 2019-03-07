#
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: opscode-certificate
# Recipe:: library
#
# Copyright 2009, Opscode, Inc.
#

include_recipe "opscode-base"

env = node["environment"]
app = {
  'deploy_to' => '/srv/opscode-certificate',
  'owner' => 'opscode',
  'group' => 'opscode',
  'id' => 'opscode-certificate'
}

directory app['deploy_to'] do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end

directory "#{app['deploy_to']}/shared" do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end
directory "#{app['deploy_to']}/shared/log" do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end

#r = resources(:service => "opscode-certificate")
deploy_revision app['id'] do
  use_remote = (env['opscode-certificate-remote'] || env['default-remote'])
  
  #action :force_deploy
  revision env['opscode-certificate-revision'] || env['default-revision']
  repository "git@github.com:#{use_remote}/opscode-cert-erlang.git"
  remote use_remote
  restart_command "if test -L /etc/sv/opscode-certificate; then sudo /etc/init.d/opscode-certificate restart; fi"
  symlink_before_migrate Hash.new
  user app['owner']
  group app['group']
  deploy_to app['deploy_to']
  migrate false

  before_symlink do
    bash "finalize_update" do
      user "root"
      cwd "#{release_path}"
      code <<-EOH
              export HOME=/tmp
              cd #{release_path} && make clean
              cd #{release_path} && make
              cd #{release_path}/deps/webmachine && make
              cd #{release_path}/deps/webmachine/deps/mochiweb && make
      EOH
    end
  end
  
  notifies :restart, "service[opscode-certificate]"
end

