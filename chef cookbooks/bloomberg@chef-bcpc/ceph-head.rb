#
# Cookbook Name:: bcpc
# Recipe:: ceph-head
#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "bcpc::ceph-common"

bash 'ceph-mon-mkfs' do
    code <<-EOH
        mkdir -p /var/lib/ceph/mon/ceph-#{node['hostname']}
        ceph-mon --mkfs -i "#{node['hostname']}" --keyring "/etc/ceph/ceph.mon.keyring"
    EOH
    not_if "test -f /var/lib/ceph/mon/ceph-#{node['hostname']}/keyring"
end

template '/etc/init/ceph-mon-renice.conf' do
  source 'ceph-upstart.ceph-mon-renice.conf.erb'
  mode 00644
  notifies :restart, "service[ceph-mon-renice]", :immediately
end

service 'ceph-mon-renice' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
  restart_command 'service ceph-mon-renice restart'
end


execute "ceph-mon-start" do
    command "initctl emit ceph-mon id='#{node['hostname']}'"
end

ruby_block "add-ceph-mon-hints" do
    block do
        get_ceph_mon_nodes.each do |server|
            system "ceph --admin-daemon /var/run/ceph/ceph-mon.#{node['hostname']}.asok " +
                "add_bootstrap_peer_hint #{server['bcpc']['storage']['ip']}:6789"
        end
    end
    # not_if checks to see if all head node IPs are in the mon list
    not_if {
      mon_list = %x[ceph mon stat]
      get_ceph_mon_nodes.collect{ |x| x['bcpc']['storage']['ip'] }.map{ |ip| mon_list.include? ip }.uniq == [true]
    }
end

ruby_block "wait-for-mon-quorum" do
    block do
        clock = 0
        sleep_time = 2
        timeout = 120
        status = { 'state' => '' }
        until %w{leader peon}.include?(status['state']) do
            if clock >= timeout
              fail "Exceeded quorum wait timeout of #{timeout} seconds, check Ceph status with ceph -s and ceph health detail"
            end
            Chef::Log.warn("Waiting for ceph-mon to get quorum...")
            status = JSON.parse(%x[ceph --admin-daemon /var/run/ceph/ceph-mon.#{node['hostname']}.asok mon_status])
            clock += sleep_time
            sleep sleep_time unless %w{leader peon}.include?(status['state'])
        end
    end
end

%w(quorum_status monstatus).each do |script|
  template "/etc/sudoers.d/#{script}" do
    source "sudoers-#{script}.erb"
    mode 0440
    owner 'root'
    group 'root'
  end
end

%w(
  get_quorum_status get_monstatus
  if_leader if_not_leader if_quorum if_not_quorum
).each do |script|
  template "/usr/local/bin/#{script}" do
    source "ceph-#{script}.erb"
    mode 0755
    owner 'root'
    group 'root'
  end
end

bash "initialize-ceph-admin-and-osd-config" do
    code <<-EOH
        ceph --name mon. --keyring /var/lib/ceph/mon/ceph-#{node['hostname']}/keyring \
            auth get-or-create-key client.admin \
            mon 'allow *' \
            osd 'allow *' \
            mds 'allow' > /dev/null
        ceph --name mon. --keyring /var/lib/ceph/mon/ceph-#{node['hostname']}/keyring \
            auth get-or-create-key client.bootstrap-osd \
            mon 'allow profile bootstrap-osd' > /dev/null
    EOH
end

bash "set-ceph-crush-tunables" do
    code <<-EOH
        ceph --name mon. --keyring /var/lib/ceph/mon/ceph-#{node['hostname']}/keyring \
            osd crush tunables optimal
    EOH
    # do not apply if any tunables have been modified from their defaults
    not_if do
      show_tunables = Mixlib::ShellOut.new('ceph osd crush show-tunables')
      show_tunables.run_command
      raise 'Could not check Ceph tunables' if show_tunables.error!
      JSON.load(show_tunables.stdout) != node['bcpc']['ceph']['expected_tunables']
    end
end

template "/tmp/crush-map-additions.txt" do
    source "ceph-crush.erb"
    owner "root"
    mode 00644
end

bash "ceph-get-crush-map" do
    code <<-EOH
        false; while (($?!=0)); do
            echo Trying to get crush map...
            sleep 1
            ceph osd getcrushmap -o /tmp/crush-map
        done
        crushtool -d /tmp/crush-map -o /tmp/crush-map.txt
    EOH
end

bash "ceph-add-crush-rules" do
    code <<-EOH
        cat /tmp/crush-map-additions.txt >> /tmp/crush-map.txt
        crushtool -c /tmp/crush-map.txt -o /tmp/crush-map-new
        ceph osd setcrushmap -i /tmp/crush-map-new
    EOH
    not_if "grep ssd /tmp/crush-map.txt"
end

# Create the VMs pool and any others that may need creating
ruby_block "create-rados-pool-#{node['bcpc']['ceph']['vms']['name']}" do
  block do
    vms_rule = (node['bcpc']['ceph']['vms']['type'] == "ssd") ? node['bcpc']['ceph']['ssd']['ruleset'] : node['bcpc']['ceph']['hdd']['ruleset']
    %x(
      ceph osd pool create #{node['bcpc']['ceph']['vms']['name']} #{get_ceph_optimal_pg_count('vms')};
      ceph osd pool set #{node['bcpc']['ceph']['vms']['name']} crush_ruleset #{vms_rule};
      sleep 15
    )
  end
  not_if "rados lspools | grep ^#{node['bcpc']['ceph']['vms']['name']}$"
end

# Commented out 'data' and 'metadata' since the number of pools can impact pgs
# data metadata - removed from loop below - After firefly data and metadata are no longer default pools

rule = (node['bcpc']['ceph']['default']['type'] == "ssd") ? node['bcpc']['ceph']['ssd']['ruleset'] : node['bcpc']['ceph']['hdd']['ruleset']

["rbd"].each do |pool|
  bash "move-#{pool}-rados-pool" do
    user "root"
    code "ceph osd pool set #{pool} crush_ruleset #{rule}"
    only_if { get_ceph_mon_nodes.length == 1 }
  end
end


# data metadata - removed from list since they are no longer created by default in ceph
["rbd", node['bcpc']['ceph']['vms']['name']].each do |pool|
  ruby_block "set-#{pool}-rados-pool-replicas" do
    block do
      %x(ceph osd pool set #{pool} size #{get_ceph_replica_count('default')})
    end
    not_if "ceph osd pool get #{pool} size | grep #{get_ceph_replica_count('default')}"
  end
end

# mds is only used by CephFS so need for it here at this time but will remain until mds is removed
%w{mon}.each do |svc|
    %w{done upstart}.each do |name|
        file "/var/lib/ceph/#{svc}/ceph-#{node['hostname']}/#{name}" do
            owner "root"
            group "root"
            mode "0644"
            action :create
        end
    end
end

bash "create-ceph-cinder-user" do
  user "root"
  code "ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes-ssd,allow rwx pool=volumes-hdd, allow rwx pool=vms, allow rx pool=images'"
  not_if "ceph auth get client.cinder"
end

bash "create-ceph-glance-user" do
  user "root"
  code "ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'"
  not_if "ceph auth get client.glance"
end

bash "create-ceph-cinder-keyring" do
  user "root"
  code "ceph auth get-or-create client.cinder  > /etc/ceph/ceph.client.cinder.keyring"
  not_if "test -f  /etc/ceph/ceph.client.cinder.keyring"
end

ruby_block "store-cinder-ceph-key" do
  block do
    make_config("cinder-ceph-key", `ceph auth get-key client.cinder`, force=true)
  end
  only_if { File.exist?('/etc/ceph/ceph.client.cinder.keyring') and ((config_defined('cinder-ceph-key') and (get_config('cinder-ceph-key') != `ceph auth get-key client.cinder`)) or (not config_defined('cinder-ceph-key'))) }
end

bash "create-ceph-glance-keyring" do
  user "root"
  code "ceph auth get-or-create client.glance  > /etc/ceph/ceph.client.glance.keyring"
  not_if "test -f  /etc/ceph/ceph.client.glance.keyring"
end

ruby_block "store-glance-ceph-key" do
  block do
    make_config("glance-ceph-key", `ceph auth get-key client.glance`, force=true)
  end
  only_if { File.exist?('/etc/ceph/ceph.client.glance.keyring') and ((config_defined('glance-ceph-key') and (get_config('glance-ceph-key') != `ceph auth get-key client.glance`)) or (not config_defined('glance-ceph-key'))) }
end
