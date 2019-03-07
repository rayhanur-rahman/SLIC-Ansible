

node["nginx"]["lua"]["packages"].each do |package_name|
  package package_name do
    action :install
  end
end

devel_kit_filename = ::File.basename(node['nginx']['lua']['url'])
lua_nginx_module_filename = ::File.basename(node['nginx']['ngx_devel_kit']['url'])

devel_kit_extract_path = "#{Chef::Config['file_cache_path']}/devel_kit/#{node['nginx']['ngx_devel_kit']['check_sum']}"
lua_nginx_module_extract_path = "#{Chef::Config['file_cache_path']}/lua_module/#{node['nginx']['lua']['check_sum']}"

devel_kit_src_filepath = "#{Chef::Config['file_cache_path']}/#{devel_kit_filename}"
lua_nginx_module_src_filepath = "#{Chef::Config['file_cache_path']}/#{lua_nginx_module_filename}"

remote_file devel_kit_src_filepath do
  source node['nginx']['ngx_devel_kit']['url']
  checksum node['nginx']['ngx_devel_kit']['check_sum']
  owner "root"
  group "root"
  mode 00644
end

remote_file lua_nginx_module_src_filepath do
  source node['nginx']['lua']['url']
  checksum node['nginx']['lua']['check_sum']
  owner "root"
  group "root"
  mode 00644
end


bash "extract_devel_kit" do
  cwd ::File.dirname(devel_kit_src_filepath)
  code <<-EOH
    mkdir -p #{devel_kit_extract_path}
    tar xzf #{devel_kit_filename} -C #{devel_kit_extract_path}
    mv #{devel_kit_extract_path}/*/* #{devel_kit_extract_path}/
  EOH

  not_if { ::File.exists?(devel_kit_extract_path) }
end

bash "extract_lua_module" do
  cwd ::File.dirname(lua_nginx_module_src_filepath)
  code <<-EOH
    mkdir -p #{lua_nginx_module_extract_path}
    tar xzf #{lua_nginx_module_filename} -C #{lua_nginx_module_extract_path}
    mv #{lua_nginx_module_extract_path}/*/* #{lua_nginx_module_extract_path}/
  EOH

  not_if { ::File.exists?(lua_nginx_module_extract_path) }
end

ENV['LUAJIT_LIB'] = node['nginx']['lua']['jit']['lib']
ENV['LUAJIT_INC'] = node['nginx']['lua']['jit']['inc']


node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{devel_kit_extract_path}",
                                             "--add-module=#{lua_nginx_module_extract_path}"]
