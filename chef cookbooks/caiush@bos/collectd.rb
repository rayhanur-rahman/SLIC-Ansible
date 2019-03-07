cookbook_file "/tmp/collectd.tgz" do
  source "bins/collectd.tgz"
  owner "root"
  mode 00444
end

user "collectd" do
  shell "/bin/false"
  home "/var/log"
  gid "adm"
  system true
end

bash "install collectd" do
  code <<-EOH
     tar zxf /tmp/collectd.tgz -C /usr/local
  EOH
  not_if "test -f /usr/local/sbin/collectd"
end

template "/etc/init/collectd.conf" do
  source "upstart-collectd.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[collectd]", :delayed
end

template  "/usr/local/etc/collectd.conf" do
  source "collectd.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[collectd]", :delayed
end

directory "/usr/local/lib/collectd/python-modules" do
  owner "root"
  group "root"
  mode 00755
  recursive true
end 

directory "/usr/local/etc/collectd.d" do
  owner "root"
  group "root"
  mode 00755
end 

cookbook_file "/usr/local/lib/collectd/python-modules/collectd-ceph.py" do
  source "bins/collectd-ceph.py"
  owner "root"
  mode 00744
end

cookbook_file "/usr/local/lib/collectd/python-modules/collectd-rgw-buckets.py" do
  source "collectd-rgw-buckets.py"
  owner "root"
  mode 00744
end

service "collectd" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
