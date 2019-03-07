#
# Cookbook Name:: pxc
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

package "mysql-server" do
    action :purge
end


include_recipe "percona::repo"

case node["platform_family"]
when "debian"
    ["mysql-client", "mysql-common"].each do |p|
        package p do
            action :purge
        end
    end
    package "percona-xtradb-cluster-server-5.5"
when "rhel"
    # Percona XtraDB Cluster depends on this.
    # http://www.percona.com/doc/percona-xtradb-cluster/5.5/installation/yum_repo.html
    include_recipe "epel"
    package "socat" 

    yum_package "Percona-XtraDB-Cluster-server-55" do
        options "--exclude mysql"
    end
end

service "mysql" do
    action [ :disable, :stop ]
end
