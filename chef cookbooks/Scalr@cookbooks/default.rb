default["memcached"]["memory"] = 64
default["memcached"]["port"] = 11211
default["memcached"]["listen"] = "0.0.0.0"
default['memcached']['maxconn'] = 1024

case node['platform_family']
when 'rhel'
    default['memcached']['user'] = 'memcached'
when 'debian'
    default['memcached']['user'] = 'nobody'
end
