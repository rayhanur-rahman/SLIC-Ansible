# Settings
set :repository, "https://github.com/eballance/rails-forum-cz.git"
set :machine,     "r01.avatech.cz"
# set :ssh_options, {:forward_agent => true}
set :bundle_flags, "--deployment --binstubs" # --quiet

# Roles
role :app, "#{machine}"
role :web, "#{machine}"
role :db, "#{machine}", :primary => true

# Core strategy
default_run_options[:pty] = true
default_run_options[:shell] = '/bin/bash --login'
set :use_sudo, false

# set :group, "www-data"

# SCM
set :scm, :git
set :git_shallow_clone, 1
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_exclude, %w(test .git doc)

# Bundler
# set :bundle_cmd, "/usr/local/bin/bundle"
# set (:bundle_cmd) { "#{release_path}/bin/bundle" }

# Symlinks
set :normal_symlinks,
    [ 'config/database.yml',
      'config/redis.yml',
      'config/discourse.conf' ]

set :directory_symlinks, {
    'assets' => 'public/assets',
    'ckeditor_assets' => 'public/ckeditor_assets',
    'uploads' => 'public/uploads'
}

# Miscs
set :keep_releases, 3
after "deploy:update", "deploy:cleanup"
after "deploy:update_symlinks", "deploy:migrate"

set :normalize_asset_timestamps, false
set(:cw_log_file) { "#{current_path}/log/clockwork.log" }
set(:cw_pid_file) { "#{current_path}/tmp/pids/clockwork.pid" }
