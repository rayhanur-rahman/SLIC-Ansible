include_recipe "opscode-github"

nginx_version = node[:nginx][:version]
package "libpcre3"
package "libpcre3-dev"
package "libssl-dev"

directory "/srv/nginx" do
  owner "opscode"
  group "opscode"
  mode '2775'
  recursive true
end

src_dir = "/tmp/nginx-src/#{nginx_version}"
dest_dir = "/srv/nginx/#{nginx_version}"

env = node["environment"]
directory src_dir do
  owner "opscode"
  group "opscode"
  mode '2775'
  recursive true
end

deploy_revision "nginx-#{nginx_version}-src" do
  #action :force_deploy
  revision (env["nginx-#{nginx_version}-revision"] || env['default-revision'])
  repository 'git@github.com:' + (env["nginx-#{nginx_version}-remote"] || env['default-remote']) + "/nginx-sysoev.git"
  symlink_before_migrate Hash.new
  user "opscode"
  group "opscode"
  deploy_to src_dir
  migrate false
  before_symlink do
    execute "./configure --conf-path=/etc/nginx --prefix=#{dest_dir} --with-http_ssl_module --with-http_stub_status_module" do
      cwd "#{release_path}"
    end
    execute "make" do
      cwd "#{release_path}"
    end
    execute "make install" do
      cwd "#{release_path}"
    end
    execute "rm /etc/nginx" do
      cwd "#{release_path}"
      not_if do File.directory?("/etc/nginx"); end
    end
  end
end

directory node[:nginx][:dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

directory "#{node[:nginx][:dir]}/sites-available" do
  owner "root"
  group "root"
  mode "0755"
end

directory "#{node[:nginx][:dir]}/sites-enabled" do
  owner "root"
  group "root"
  mode "0755"
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/logrotate.d/nginx" do
  source "logrotate-nginx.erb"
  owner "root"
  group "root"
  mode "0644"
end
