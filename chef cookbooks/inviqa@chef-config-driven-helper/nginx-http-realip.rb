template "#{node['nginx']['dir']}/conf.d/http_realip.conf" do
  source 'http_realip.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  variables({
    :real_ip_from => node['nginx']['real_ip_from'],
    :real_ip_header => node['nginx']['real_ip_header'],
    :real_ip_recursive => node['nginx']['real_ip_recursive']
  })
  notifies :reload, 'service[nginx]'
end
