# Install Development tools to compile the sofether vpnserver source
%w( make gcc ).each do |pkg|
  package pkg do
    action :install
  end
end

install_directory = '/opt/vpnserver'
download_url = 'http://www.softether-download.com/files/softether/v4.27-9666-beta-2018.04.21-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.27-9666-beta-2018.04.21-linux-x64-64bit.tar.gz'

# Create install directory
directory install_directory do
  action :create
end

template "#{install_directory}/#{node['bubble']['softethervpn-config']}" do
  source "softether/#{node['bubble']['softethervpn-config']}.erb"
  variables(
    softethervpn_psk: node['bubble']['softethervpn-psk']
  )
  owner 'root'
  group 'root'
  mode '0664'
  action :create
end

execute 'configure_softethervpn' do
  cwd install_directory
  command "./vpncmd localhost /SERVER /IN:#{node['bubble']['softethervpn-config']}"
  action :nothing
end

# Unpack and compile softether-vpnserver
execute 'unpack_softether_vpn' do
  command "tar xvf #{Chef::Config[:file_cache_path]}/softether-vpnserver.tar.gz -C #{install_directory} --strip-components=1 && cd #{install_directory} && yes 1 | make"
  action :nothing
  notifies :run, 'execute[configure_softethervpn]', :delayed
end

# Download softether vpnserver and create the intallation directory
remote_file "#{Chef::Config[:file_cache_path]}/softether-vpnserver.tar.gz" do
  source download_url
  mode '0755'
  action :create_if_missing
  notifies :run, 'execute[unpack_softether_vpn]', :immediately
end

# Install systemd service for softether server
cookbook_file '/etc/systemd/system/softether-vpnserver.service' do
  source 'softether/softether-vpnserver.service'
  owner 'root'
  owner 'root'
  mode '0644'
  action :create_if_missing
end

# Enable and start the softether server service
service 'softether-vpnserver' do
  action [:enable, :start]
end
