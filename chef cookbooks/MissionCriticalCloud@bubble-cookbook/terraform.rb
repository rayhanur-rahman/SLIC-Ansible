# Use Chef cache as tmp location
tmp_loc = Chef::Config[:file_cache_path]

remote_file "#{tmp_loc}/terraform.zip" do
  source node['bubble']['terraform_download_url']
  mode '0644'
  backup false
end

bash 'unzip_terraform' do
  user 'root'
  cwd "#{tmp_loc}"
  code <<-EOH
  unzip -o terraform.zip
  EOH
end

remote_file 'move_terraform_binary' do
  path '/usr/local/bin/terraform'
  source "file://#{tmp_loc}/terraform"
  owner 'root'
  group 'root'
  mode 0755
end
