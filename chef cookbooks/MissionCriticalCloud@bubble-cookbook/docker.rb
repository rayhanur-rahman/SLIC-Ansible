# Add docker service.
if `/usr/sbin/ip a`.include? "virbr0"
  docker_service 'default' do
    host ['unix:///var/run/docker.sock', 'tcp://127.0.0.1:2375']
    group node['bubble']['group_name']
    bridge 'virbr0'
    fixed_cidr '192.168.22.224/27'
    action [:create, :start]
    notifies :create, 'cookbook_file[/opt/bin/dnsthing.py]'
    notifies :create, 'cookbook_file[/etc/systemd/system/dnsthing.service]'
  end
end

# Add a user for coredns
user 'coredns' do
  comment 'coredns user'
  gid node['bubble']['group_name']
  home '/home/coredns'
  shell '/bin/bash'
  manage_home true
end

# Create directory for coredns binary
directory '/opt/bin' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Add coredns binary
cookbook_file '/opt/bin/coredns' do
  source 'coredns/coredns'
  owner 'coredns'
  group node['bubble']['group_name']
  mode '0755'
  action :create
end

# Create directory for coredns config
directory '/etc/coredns' do
  owner 'coredns'
  group node['bubble']['group_name']
  mode '0755'
  action :create
end

# Add coredns config
template '/etc/coredns/Corefile' do
  source 'coredns/Corefile.erb'
  owner 'coredns'
  group node['bubble']['group_name']
  mode '0755'
  action :create
  notifies :restart, 'service[coredns]', :delayed
end

# Install systemd service for coredns server
cookbook_file '/etc/systemd/system/coredns.service' do
  source 'coredns/coredns.service'
  owner 'root'
  owner 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[coredns]', :delayed
end

# Make sure a zone file exists.
file '/home/coredns/docker.cloud.lan' do
  content ''
  mode '0755'
  owner 'coredns'
  group node['bubble']['group_name']
  action :create_if_missing
end

# Enable and start the coredns server service
service 'coredns' do
  action [:enable, :start]
end

# Add dnsthing binary
cookbook_file '/opt/bin/dnsthing.py' do
  source 'coredns/dnsthing.py'
  owner 'coredns'
  group node['bubble']['group_name']
  mode '0755'
  action :nothing
  notifies :restart, 'service[dnsthing]', :delayed
end

# Install systemd service for dnsthing server
cookbook_file '/etc/systemd/system/dnsthing.service' do
  source 'coredns/dnsthing.service'
  owner 'root'
  owner 'root'
  mode '0644'
  action :nothing
  notifies :restart, 'service[dnsthing]', :delayed
end

python_pip 'docker-py'

# Enable and start the dnsthing server service
service 'dnsthing' do
  action [:enable, :start]
  only_if { ::File.exist?('/etc/systemd/system/dnsthing.service') }
end
