# Use Chef cache as tmp location
tmp_loc = Chef::Config[:file_cache_path]

remote_file "#{tmp_loc}/helm.tar.gz" do
  source node['bubble']['helm_download_url']
  backup false
  notifies  :run, 'execute[Extract helm package]', :immediately
end

execute 'Extract helm package' do
  command "tar xvf #{tmp_loc}/helm.tar.gz -C #{tmp_loc}"
  action :nothing
  notifies :create, 'remote_file[Copy helm binary]', :immediately
end

remote_file 'Copy helm binary' do
  path '/usr/local/bin/helm'
  source "file://#{tmp_loc}/linux-amd64/helm"
  owner 'root'
  group 'root'
  mode 0755
  backup false
  action :nothing
end

bash 'helm_tabcompletion' do
  code 'echo "source <(helm completion)" >> /etc/bashrc'
  not_if { `cat /etc/bashrc`.include? 'source <(helm completion)' }
end
