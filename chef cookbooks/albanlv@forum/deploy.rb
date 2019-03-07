require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :app, 'sharelex-discourse'
set :user, 'zdun'
set :port, '969'
set :domain, '46.4.63.15'
set :deploy_to, "/home/#{user}/apps/#{app}"
set :repository, "https://github.com/ShareLex/forum.git"
set :branch, 'master'

set :shared_paths, ['config/database.yml', 'config/redis.yml', 'log']

set_default :chruby, "/etc/profile.d/chruby.sh"

task :environment do
  queue %{
    echo "-----> Loading guns and chruby"
    #{echo_cmd %{source #{chruby}}}
    #{echo_cmd %{chruby ruby-2.1.0}}
  }
  queue %{
    echo "-----> Setting RAILS_ROOT and preparing the carrots"
    #{echo_cmd %{export RAILS_ROOT=#{deploy_to}}}
  }
  queue %[export SECRET_TOKEN="47f3390334cf6d25bc97083fb98e7c47f5390004bf6d25bb97083fb98e7c"]
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo ------> Be sure to edit 'shared/config/database.yml'.]
end

task :nginx => :environment do
  queue %{
    echo "----> Setting RAILS_ROOT"
    #{echo_cmd %{export RAILS_ROOT=#{deploy_to}}}
  }
  queue! %[sudo ln -nfs "#{deploy_to}/current/config/nginx.conf" "/etc/nginx/sites-enabled/#{app}"]
  queue %[echo"Linking... #{deploy_to}/current/config/nginx.conf /etc/nginx/sites-enabled/#{app}"]
  queue! %[sudo service nginx restart]
end

desc "Deploys the current version to the server, yay."
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
#      invoke :restart
    end
  end
end

task vars: :environment do
  queue! %[. "#{deploy_to}/shared/config/env"]
end

task start: :vars do
  queue %[cd "#{deploy_to}/current" && bundle exec unicorn -D -c "#{deploy_to}/current/config/unicorn.rb" -E production]
  queue %[cd "#{deploy_to}/current" && bundle exec sidekiq -d -L "#{deploy_to}/current/log/sidekiq.log" -e production -C "#{deploy_to}/current/config/initializer/sidekig.rb" -P "#{deploy_to}/current/tmp/sidekiq.pid"]
#  queue %[cd "#{deploy_to}/current" && RAILS_ENV=production bundle exec clockworkd -c config/clock.rb --pid-dir="#{deploy_to}/current/tmp" start]
end

task stop: :vars do
#  queue %[cd "#{deploy_to}/current" && RAILS_ENV=production bundle exec clockworkd -c config/clock.rb --pid-dir="#{deploy_to}/current/tmp" stop]
  queue %[cd "#{deploy_to}/current/tmp" && bundle exec sidekiqctl stop "#{deploy_to}/current/tmp/sidekiq.pid"]
  queue %[kill -QUIT `cat "#{deploy_to}/tmp/unicorn.pid"`]
end

task :restart do
  invoke :stop
  invoke :start
end

desc "Shows logs."
task :logs do
    queue %[cd #{deploy_to!} && tail -n 500 shared/log/production.log]
end