###########################################
#
# Service catalog (API versions/endpoints)
#
###########################################

default['bcpc']['catalog'] = {
  'identity' => {
    'name' => 'keystone',
    'project' => 'keystone',
    'description' => 'OpenStack Identity',
    'ports' => {
      'admin' => 35357,
      'internal' => 5000,
      'public' => 5000
    },
    'uris' => {
      'admin' => 'v3',
      'internal' => 'v3',
      'public' => 'v3'
    }
  },
  'compute' => {
    'name' => 'Compute Service',
    'project' => 'nova',
    'description' => 'OpenStack Compute Service',
    'ports' => {
      'admin' => 8774,
      'internal' => 8774,
      'public' => 8774
    },
    'uris' => {
      'admin' => 'v2.1/%(project_id)s',
      'internal' => 'v2.1/%(project_id)s',
      'public' => 'v2.1/%(project_id)s'
    }
  },
  'volume' => {
    'name' => 'Volume Service',
    'project' => 'cinder',
    'description' => 'OpenStack Volume Service',
    'ports' => {
      'admin' => 8776,
      'internal' => 8776,
      'public' => 8776
    },
    'uris' => {
      'admin' => 'v2/%(project_id)s',
      'internal' => 'v2/%(project_id)s',
      'public' => 'v2/%(project_id)s'
    }
  },
  'volumev2' => {
    'name' => 'cinderv2',
    'project' => 'cinder',
    'description' => 'OpenStack Volume Service V2',
    'ports' => {
      'admin' => 8776,
      'internal' => 8776,
      'public' => 8776
    },
    'uris' => {
      'admin' => 'v2/%(project_id)s',
      'internal' => 'v2/%(project_id)s',
      'public' => 'v2/%(project_id)s'
    }
  },
  'image' => {
    'name' => 'Image Service',
    'project' => 'glance',
    'description' => 'OpenStack Image Service',
    'ports' => {
      'admin' => 9292,
      'internal' => 9292,
      'public' => 9292
    },
    'uris' => {
      'admin' => '',
      'internal' => '',
      'public' => ''
    }
  },
  'network' => {
    'name' => 'Network Service',
    'project' => 'neutron',
    'description' => 'OpenStack Network Service',
    'ports' => {
      'admin' => 9696,
      'internal' => 9696,
      'public' => 9696
    },
    'uris' => {
      'admin' => '',
      'internal' => '',
      'public' => ''
    }
  }
}
