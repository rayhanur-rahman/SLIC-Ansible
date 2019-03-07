###########################################
#
#  General configuration for this cluster
#
###########################################
default['bcpc']['country'] = "US"
default['bcpc']['state'] = "NY"
default['bcpc']['location'] = "New York"
default['bcpc']['organization'] = "Bloomberg"
# Define the kernel to be installed. By default, track latest LTS kernel
default['bcpc']['preseed']['kernel'] = "linux-image-generic-lts-trusty"
# Region name for this cluster
default['bcpc']['region_name'] = node.chef_environment
# Domain name for this cluster (used in many configs)
default['bcpc']['domain_name'] = "bcpc.example.com"

###########################################
#
#  Flags to enable/disable BCPC cluster features
#
###########################################
# This will enable powerdns on head nodes
default['bcpc']['enabled']['host_firewall'] = true
# This will enable of encryption of the chef data bag
default['bcpc']['enabled']['encrypt_data_bag'] = false
# This will enable auto-upgrades on all nodes (not recommended for stability)
default['bcpc']['enabled']['apt_upgrade'] = false
# This will enable the networking test scripts
default['bcpc']['enabled']['network_tests'] = true
# This will enable httpd disk caching for radosgw
default['bcpc']['enabled']['radosgw_cache'] = false
# This will enable using TPM-based hwrngd
default['bcpc']['enabled']['tpm'] = false

# If radosgw_cache is enabled, default to 20MB max file size
default['bcpc']['radosgw']['cache_max_file_size'] = 20000000

###########################################
#
#  Host-specific defaults for the cluster
#
###########################################
default['bcpc']['ceph']['hdd_disks'] = ["sdb", "sdc"]
default['bcpc']['ceph']['ssd_disks'] = ["sdd", "sde"]
default['bcpc']['ceph']['enabled_pools'] = ["ssd", "hdd"]
default['bcpc']['management']['interface'] = "eth0"
default['bcpc']['storage']['interface'] = "eth1"
default['bcpc']['floating']['interface'] = "eth2"
default['bcpc']['fixed']['vlan_interface'] = node['bcpc']['floating']['interface']

###########################################
#
#  Ceph settings for the cluster
#
###########################################
default['bcpc']['ceph']['chooseleaf'] = "rack"
default['bcpc']['ceph']['pgp_auto_adjust'] = false
default['bcpc']['ceph']['pgs_per_node'] = 1024
# The 'portion' parameters should add up to ~100 across all pools
default['bcpc']['ceph']['default']['replicas'] = 2
default['bcpc']['ceph']['default']['type'] = 'hdd'
default['bcpc']['ceph']['rgw']['replicas'] = 3
default['bcpc']['ceph']['rgw']['portion'] = 33
default['bcpc']['ceph']['rgw']['type'] = 'hdd'
default['bcpc']['ceph']['ssd']['ruleset'] = 1
default['bcpc']['ceph']['hdd']['ruleset'] = 2

# If you are about to make a big change to the ceph cluster
# setting to true will reduce the load form the resulting
# ceph rebalance and keep things operational. 
# See wiki for further details. 
default['bcpc']['ceph']['rebalance'] = false

###########################################
#
#  Network settings for the cluster
#
###########################################
default['bcpc']['management']['vip'] = "10.17.1.15"
default['bcpc']['management']['netmask'] = "255.255.255.0"
default['bcpc']['management']['cidr'] = "10.17.1.0/24"
default['bcpc']['management']['gateway'] = "10.17.1.1"
default['bcpc']['management']['interface'] = nil
default['bcpc']['management']['monitoring']['vip'] = "10.17.1.16"
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['management']['interface-parent'] = nil

default['bcpc']['metadata']['ip'] = "169.254.169.254"

default['bcpc']['storage']['netmask'] = "255.255.255.0"
default['bcpc']['storage']['cidr'] = "100.100.0.0/24"
default['bcpc']['storage']['gateway'] = "100.100.0.1"
default['bcpc']['storage']['interface'] = nil
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['storage']['interface-parent'] = nil

default['bcpc']['floating']['vip'] = "192.168.43.15"
default['bcpc']['floating']['netmask'] = "255.255.255.0"
default['bcpc']['floating']['cidr'] = "192.168.43.0/24"
default['bcpc']['floating']['gateway'] = "192.168.43.2"
default['bcpc']['floating']['available_subnet'] = "192.168.43.128/25"
default['bcpc']['floating']['interface'] = nil
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['floating']['interface-parent'] = nil

default['bcpc']['fixed']['cidr'] = "1.127.0.0/16"
default['bcpc']['fixed']['vlan_start'] = "1000"
default['bcpc']['fixed']['num_networks'] = "100"
default['bcpc']['fixed']['network_size'] = "256"
default['bcpc']['fixed']['dhcp_lease_time'] = "120"

default['bcpc']['ntp_servers'] = ["pool.ntp.org"]
default['bcpc']['dns_servers'] = ["8.8.8.8", "8.8.4.4"]

###########################################
#
#  Repos for things we rely on
#
###########################################
default['bcpc']['repos']['ceph'] = "http://www.ceph.com/debian-firefly"
default['bcpc']['repos']['ceph-extras'] = "http://www.ceph.com/packages/ceph-extras/debian"
default['bcpc']['repos']['ceph-el6-x86_64'] = "http://ceph.com/rpm-dumpling/el6/x86_64"
default['bcpc']['repos']['ceph-el6-noarch'] = "http://ceph.com/rpm-dumpling/el6/noarch"
default['bcpc']['repos']['rabbitmq'] = "http://www.rabbitmq.com/debian"
default['bcpc']['repos']['mysql'] = "http://repo.percona.com/apt"
default['bcpc']['repos']['haproxy'] = "http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu"
default['bcpc']['repos']['openstack'] = "http://ubuntu-cloud.archive.canonical.com/ubuntu"
default['bcpc']['repos']['hwraid'] = "http://hwraid.le-vert.net/ubuntu"
default['bcpc']['repos']['fluentd'] = "http://packages.treasure-data.com/precise"
default['bcpc']['repos']['ceph-apache'] = "http://gitbuilder.ceph.com/apache2-deb-precise-x86_64-basic/ref/master"
default['bcpc']['repos']['ceph-fcgi'] = "http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-precise-x86_64-basic/ref/master"
default['bcpc']['repos']['gridcentric'] = "http://downloads.gridcentric.com/packages/%s/%s/ubuntu"

###########################################
#
# [Optional] If using apt-mirror to pull down repos, we use these settings.
#
###########################################
# Note - us.archive.ubuntu.com tends to rate-limit pretty hard.
# If you are on East Coast US, we recommend Columbia University in env file:
# "mirror" : {
#  "ubuntu": "mirror.cc.columbia.edu/pub/linux/ubuntu/archive"
# }
# For a complete list of Ubuntu mirrors, please see:
# https://launchpad.net/ubuntu/+archivemirrors
default['bcpc']['mirror']['ubuntu'] = "us.archive.ubuntu.com/ubuntu"
default['bcpc']['mirror']['ubuntu-dist'] = ['precise']
default['bcpc']['mirror']['ceph-dist'] = ['firefly']
default['bcpc']['mirror']['os-dist'] = ['icehouse']

###########################################
#
#  Default names for db's, pools, and users
#
###########################################

default['bcpc']['admin_email'] = "admin@localhost.com"


default['bcpc']['ports']['apache']['radosgw'] = 80
default['bcpc']['ports']['apache']['radosgw_https'] = 443
default['bcpc']['ports']['haproxy']['radosgw'] = 80
default['bcpc']['ports']['haproxy']['radosgw_https'] = 443

default['bcpc']['collectd']['udp_ip'] = "10.0.100.3"
default['bcpc']['collectd']['udp_port'] = "25826"
default['bcpc']['collectd']['log_local'] = true
default['bcpc']['collectd']['ceph_debug'] = true
