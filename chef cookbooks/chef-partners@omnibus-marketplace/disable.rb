include_recipe "chef-marketplace::config"
include_recipe "chef-marketplace::_publishing_disable"

role = node["chef-marketplace"]["role"] # 'server', 'analytics', 'aio'

include_recice "chef-marketplace::_#{role}_disable"
