require "bundler/capistrano"
after "deploy:restart", "resque:restart"

set :application, "dentonator"
server "digodave", :web, :app, :db, primary: true

set :user, "root"
set :appstage, "dentonator"
set :use_sudo, false

set :scm, 'git'
set :deploy_to, "/u/apps/#{application}"
set :branch, "master"
set :scm_verbose, true

set :application_server, :unicorn
set :repository, "git@github.com:Villag/dentonator.git"

set :database_adapter,  "postgresql"
set :database_password, "cornkits"
set :database_username, "postgres"

set :rails_env, :production
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

load 'deploy/assets'

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end

  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{try_sudo} bundle exec unicorn -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do
    pid = `cat #{unicorn_pid}`
    run "#{try_sudo} kill #{pid}" unless pid.empty?
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end
