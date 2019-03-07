#
# Cookbook Name:: deploy
# Recipe:: pre-deploy
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory '/home/ubuntu/deploy' do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
end

directory '/home/ubuntu/.ssh' do
  owner 'ubuntu'
  group 'ubuntu'
  mode  '0700'
  recursive true
end

cookbook_file '/home/ubuntu/.ssh/git-ssh' do
  source 'git-ssh'
  owner 'ubuntu'
  mode '0600'
end

cookbook_file '/home/ubuntu/deploy/wrap-ssh4git.sh' do
  source 'wrap-ssh4git.sh'
  owner 'ubuntu'
  mode '0755'
end
