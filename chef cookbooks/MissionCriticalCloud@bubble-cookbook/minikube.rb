# Use Chef cache as tmp location
tmp_loc = Chef::Config[:file_cache_path]

remote_file '/usr/local/bin/kubectl' do
  source node['bubble']['kubectl_download_url']
  mode '0755'
  backup false
end

remote_file '/usr/local/bin/docker-machine-driver-kvm' do
  source node['bubble']['docker-machine-driver-kvm_download_url']
  mode '0755'
  backup false
end

remote_file '/usr/local/bin/minikube' do
  source node['bubble']['minikube_download_url']
  mode '0755'
  backup false
end

bash 'kubectl_tabcompletion' do
  code 'echo "source <(kubectl completion bash)" >> /etc/bashrc'
  not_if { `cat /etc/bashrc`.include? 'source <(kubectl completion bash)' }
end

# Import libvirt configurations
cookbook_file "#{tmp_loc}/net_docker-machines.xml" do
  source 'libvirt/net_docker-machines.xml'
  owner 'root'
  group 'root'
  mode 00644
  not_if { ::File.exist?('/etc/libvirt/qemu/networks/docker-machines.xml') }
end

bash 'Configure_docker-machines_network' do
  user 'root'
  cwd "#{tmp_loc}"
  code <<-EOH
  virsh net-define net_docker-machines.xml
  virsh net-start docker-machines
  virsh net-autostart docker-machines
  EOH
  not_if { ::File.exist?('/etc/libvirt/qemu/networks/docker-machines.xml') }
  notifies :request_reboot, 'reboot[Reboot for networking]', :delayed
end
