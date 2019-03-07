remote_file "/tmp/epel-release-7-5.noarch.rpm" do
  source "ftp://ftp.muug.mb.ca/mirror/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm"
  owner "root"
  group "root"
  mode "0644"
  action :create
  only_if { mirrors_reachable? }
end

remote_file "/tmp/python-pygments-1.4-9.el7.noarch.rpm" do
  source "ftp://ftp.muug.mb.ca/mirror/centos/7.1.1503/os/x86_64/Packages/python-pygments-1.4-9.el7.noarch.rpm"
  owner "root"
  group "root"
  mode "0644"
  action :create
  only_if { mirrors_reachable? }
end

package "epel-release-7-5" do
  action :install
  source "/tmp/epel-release-7-5.noarch.rpm"
  provider Chef::Provider::Package::Rpm
  only_if { mirrors_reachable? }
end

package "python-imaging" do
  action :install
  only_if { mirrors_reachable? }
end

package "python-pygments" do
  action :install
  source "/tmp/python-pygments-1.4-9.el7.noarch.rpm"
  provider Chef::Provider::Package::Rpm
  only_if { mirrors_reachable? }
end
