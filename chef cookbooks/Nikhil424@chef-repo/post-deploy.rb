#
# Cookbook Name:: deploy
# Recipe:: post-deploy
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/home/ubuntu/migrate.sh' do
  source 'migrate.sh'
  owner 'ubuntu'
  mode '0755'
end

execute 'running_migrate.sh' do
  command '/home/ubuntu/./migrate.sh'
  user 'ubuntu'
end

