#
# Cookbook Name:: deploy
# Recipe:: rollback
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe 'git::default'
include_recipe 'deploy::credentials'

deploy_code 'code_deployment' do
  action :rollback
end
