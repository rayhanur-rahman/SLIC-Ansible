# Vhost generation

namespace :nginx do
  desc "Create Nginx virtual host configuration file"
  task :create_vhost, :roles => :web do
    run "mkdir -p #{shared_path}/config"
    template = File.read(File.join(File.dirname(__FILE__), "nginx_vhost.conf.erb"))
    buffer   = ERB.new(template).result(binding)
    put buffer, "#{shared_path}/config/nginx_vhost.conf"
    run "mkdir -p #{shared_path}/log"

    #put "", "#{shared_path}/log/access.log" # create empty access log
  end
end

after 'deploy:setup', 'nginx:create_vhost'
