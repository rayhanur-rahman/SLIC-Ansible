# Symlinks

desc "Copy configuration files to shared directory"
task :copy_configs_to_shared, :roles => :app do
  run "mkdir -p #{shared_path}/config"
  put(File.read('config/database.yml'), "#{shared_path}/config/database.yml", :mode => 0640)
end

after "deploy:setup", "copy_configs_to_shared"

desc "Setup shared directories"
task :setup_shared_directories, :roles => :app do
  directory_symlinks
  run "mkdir -p #{shared_path}/assets #{shared_path}/ckeditor_assets #{shared_path}/uploads #{shared_path}/backup #{shared_path}/db"
end

after "deploy:setup", "setup_shared_directories"

namespace :deploy do
  desc "Update all the damn symlinks"
  task :update_symlinks, :roles => :app, :except => { :no_release => true } do
    commands = normal_symlinks.map do |path|
      "rm -rf #{release_path}/#{path} && \
       ln -s #{shared_path}/#{path} #{release_path}/#{path}"
    end

    commands += directory_symlinks.map do |from, to|
      "rm -rf #{release_path}/#{to} && \
       ln -s #{shared_path}/#{from} #{release_path}/#{to}"
    end

    # needed for some of the symlinks
    run "mkdir -p #{release_path}/tmp"

    run <<-CMD
      cd #{release_path} && #{commands.join(" && ")}
    CMD
  end
end

# after "deploy:create_symlink", "deploy:update_symlinks"
before "deploy:assets:precompile", "deploy:update_symlinks"
