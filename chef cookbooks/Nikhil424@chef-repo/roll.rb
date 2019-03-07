resource_name :rollbackdeploy_roll

action :create do
  deploy 'nikhil_repo' do
    repo 'git@github.com:Nikhilsbhat/game-of-life.git'
    user 'ubuntu'
    deploy_to '/home/ubuntu/credentials'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    keep_releases 5
    action :rollback
    symlinks ({})
    rollback_on_error true
    ssh_wrapper '/home/ubuntu/credentials/wrap-ssh4git.sh'
  end
end
