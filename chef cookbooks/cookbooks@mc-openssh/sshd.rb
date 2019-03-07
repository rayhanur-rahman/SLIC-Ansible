# custom security settings for sshd
service "ssh" do
  supports :restart => true, :enable => true, :disable => true
  action :nothing
end

internal_ip = node[:ipaddress].scan(/192.168.\d{1,3}\.\d{1,3}|10.\d{1,3}\.\d{1,3}.\d{1,3}|172.16.\d{1,3}\.\d{1,3}/).first

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  mode "0644"
  variables(
    :port => node[:sshd][:port],
    :permit_root_login => node[:sshd][:permit_root_login],
    :password_authentication => node[:sshd][:password_authentication],
    :internal_ip => internal_ip,
    :permit_public_ssh => node["sshd"]["permit_public_ip_access"]
  )
  notifies :restart, "service[ssh]"
end
