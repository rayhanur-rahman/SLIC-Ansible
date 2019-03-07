# Upraveno z https://gist.github.com/causztic/5251078

namespace :clockwork do
  desc "Stop clockwork"
  task :stop, :roles => :app, :on_no_matching_servers => :continue do
    run "#{shared_path}/bin/clockworkctl stop"
  end

  desc "Start clockwork"
  task :start, :roles => :app, :on_no_matching_servers => :continue do
    run "#{shared_path}/bin/clockworkctl start"
  end

  desc "Restart clockwork"
  task :restart, :roles => :app, :on_no_matching_servers => :continue do
    stop
    start
  end

  namespace :setup do
    desc "Create clockworkctl file"
    task :clockworkctl, :roles => :web do
      run "mkdir -p #{shared_path}/bin"
      template = File.read(File.join(File.dirname(__FILE__), "clockworkctl.erb"))
      buffer   = ERB.new(template).result(binding)
      put buffer, "#{shared_path}/bin/clockworkctl"
      run "chmod 755 #{shared_path}/bin/clockworkctl"
    end

    desc "Create monit config"
    task :monit, :roles => :web do
      run "mkdir -p #{shared_path}/config"
      template = File.read(File.join(File.dirname(__FILE__), "clockwork.monit.erb"))
      buffer   = ERB.new(template).result(binding)
      put buffer, "#{shared_path}/config/clockwork.monit"
    end
  end
end

after "deploy:stop", "clockwork:stop"
after "deploy:start", "clockwork:start"
after "deploy:restart", "clockwork:restart"
after "deploy:cold", "clockwork:setup:clockworkctl"
