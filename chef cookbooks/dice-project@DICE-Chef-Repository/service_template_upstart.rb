resource_name 'service_template'

provides 'service_template' do
  ::File.executable?('/sbin/initctl')
end

default_action :create

property :name, String, name_property: true
property :variables, Hash, default: {}

action :create do
  template "/etc/init/#{new_resource.name}.conf" do
    source "#{new_resource.name}.conf.erb"
    variables new_resource.variables
  end
end
