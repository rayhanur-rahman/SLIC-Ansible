# Create base structure for NFS server
%w( /data/storage/secondary/MCCT-SHARED-1
    /data/storage/secondary/MCCT-SHARED-2
    /data/storage/secondary/MCCT-SHARED-3
    /data/storage/primary/MCCT-XEN-1
    /data/storage/primary/MCCT-XEN-2
    /data/storage/primary/MCCT-XEN-3
    /data/storage/primary/MCCT-KVM-1
    /data/storage/primary/MCCT-KVM-2
    /data/storage/primary/MCCT-KVM-3 ).each do |path|
  directory path do
    owner 'root'
    group node['bubble']['group_name']
    mode '0755'
    action :create
    recursive true
  end
end

# Export /data as NFS
nfs_export '/data' do
  network '192.168.22.0/24'
  writeable true
  sync true
  options ['no_root_squash', 'async', 'fsid=1']
end

# Enable and start rpcbind
service 'rpcbind' do
  action [:start, :enable]
end

# Enable and start nfs-server
service 'nfs-server' do
  action [:start, :enable]
end
