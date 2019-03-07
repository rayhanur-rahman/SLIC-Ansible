include_recipe "chef-marketplace::enable"
include_recipe "chef-marketplace::_publishing_enable"
include_recipe "chef-marketplace::_cloud_init"

role = node["chef-marketplace"]["role"]
include_recipe "chef-marketplace::_#{role}_preconfigure"
include_recipe "chef-marketplace::_security"
