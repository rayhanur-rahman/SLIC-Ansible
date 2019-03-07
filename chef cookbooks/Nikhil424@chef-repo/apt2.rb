#
# Cookbook Name:: apt2
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "apt-get update" do
  command "apt-get update"
end
