namespace :logrotate do
  desc "Create logrotate config"
  task :setup, :roles => :web do
    run "mkdir -p #{shared_path}/config"
    template = File.read(File.join(File.dirname(__FILE__), "app.logrotate.erb"))
    buffer   = ERB.new(template).result(binding)
    put buffer, "#{shared_path}/config/app.logrotate"
    run "setfacl -m u:nginx:rwx #{shared_path}/log"
  end
end

after "deploy:cold", "logrotate:setup"
