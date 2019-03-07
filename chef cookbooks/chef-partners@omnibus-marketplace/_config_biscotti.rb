case node['chef-marketplace']['role']
when 'aio', 'server'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/opscode/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/'
  node.default['chef-marketplace']['automate']['credentials'] = {}
when 'automate'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/delivery/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/setup'
  node.default['chef-marketplace']['automate']['credentials'] = {
    'admin_password' => node['chef-marketplace']['automate']['passwords']['admin_user'],
    'builder_password' => node['chef-marketplace']['automate']['passwords']['builder_user'],
  }
when 'compliance'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/chef-compliance/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/'
  node.default['chef-marketplace']['automate']['credentials'] = {}
end

uuid_type, uuid =
  case node['chef-marketplace']['platform']
  when 'google'
    ['Project Name', node['gce']['project']['projectId']]
  when 'azure'
    ['vmId', node['azure']['metadata']['compute']['vmId']]
  else # aws, testing
    ['Instance ID', node['ec2']['instance_id']]
  end

node.default['chef-marketplace']['biscotti']['nginx']['add_on_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'addon.d')
node.default['chef-marketplace']['biscotti']['nginx']['scripts_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'scripts')
node.default['chef-marketplace']['biscotti']['nginx']['biscotti_lua_file'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['scripts_dir'], 'biscotti.lua')

node.default['chef-marketplace']['biscotti']['uuid_type'] = uuid_type
node.default['chef-marketplace']['biscotti']['uuid'] = uuid

# Authorization related attributes. Right now we only really need these for AWS.
case node['chef-marketplace']['platform']
when 'aws'
  node.default['chef-marketplace']['biscotti']['message'] =
    "To begin configuring Chef Automate, enter the #{uuid_type} for the Ec2 instance. The #{uuid_type} can be found in the AWS Console."
  node.default['chef-marketplace']['biscotti']['auth_required'] = true
when 'azure'
  node.default['chef-marketplace']['biscotti']['message'] = "To begin configuring Chef Automate, enter the Azure unique vmId. The vmId can be found by logging into the instance and running the command: `sudo chef-marketplace-ctl show-instance-id`"

  node.default['chef-marketplace']['biscotti']['auth_required'] = true
else
  node.default['chef-marketplace']['biscotti']['message'] = "#{node['chef-marketplace']['platform']} is not a supported cloud provider."
  node.default['chef-marketplace']['biscotti']['auth_required'] = false
end
