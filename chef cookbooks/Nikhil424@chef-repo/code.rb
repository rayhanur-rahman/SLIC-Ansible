resource_name :deploy_code

action :deploy do
  deploy 'nikhil_repo' do
    repo 'git@github.com:Nikhilsbhat/game-of-life.git'
    user 'ubuntu'
    deploy_to '/home/ubuntu/deploy'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    action :deploy
    keep_releases 5
    symlinks ({})
    rollback_on_error true
    ssh_wrapper '/home/ubuntu/deploy/wrap-ssh4git.sh'
  end
end

action :rollback do
  deploy 'nikhil_repo' do
    repo 'git@github.com:Nikhilsbhat/game-of-life.git'
    user 'ubuntu'
    deploy_to '/home/ubuntu/deploy'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    action :rollback
    keep_releases 5
    symlinks ({})
    rollback_on_error true
    ssh_wrapper '/home/ubuntu/deploy/wrap-ssh4git.sh'
  end
end
