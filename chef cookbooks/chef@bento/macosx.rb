Vagrant.require_version ">= 1.7.3"

Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |_, override|
    override.vm.synced_folder ".", "/vagrant", type: "rsync"
  end
end
