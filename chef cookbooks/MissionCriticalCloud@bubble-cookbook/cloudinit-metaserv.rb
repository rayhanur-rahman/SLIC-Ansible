directory '/opt/cloudinit-metaserv' do
  action :create
end

cookbook_file '/opt/cloudinit-metaserv/cloud-meta.py' do
  source 'cloudinit-metaserv/cloud-meta.py'
  owner 'root'
  group 'root'
  mode 00644
  action :create_if_missing
end

template '/opt/cloudinit-metaserv/cloud-passwd.py' do
  source 'cloud-passwd.py.erb'
  variables(
    cloudinit_password: node['bubble']['cloudinit-password']
  )
end

remote_directory '/etc/supervisord.d' do
  source 'supervisord.d'
end

service 'supervisord' do
  action [:enable, :start]
end
