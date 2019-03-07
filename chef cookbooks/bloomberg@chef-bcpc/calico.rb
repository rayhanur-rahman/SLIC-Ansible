# Calico networking configuration

# attributes in here apply only if bcpc.enabled.neutron is true
default['bcpc']['calico']['fixed_network']['name'] = 'calico_int_net'
default['bcpc']['calico']['fixed_network']['subnet'] = '192.168.101.0/24'
default['bcpc']['calico']['bgp']['as_number'] = 65001
default['bcpc']['calico']['bgp']['workload_interface'] = 'floating'
default['bcpc']['calico']['bgp']['upstream_peer'] = '192.168.100.3'

