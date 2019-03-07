resource_name 'service_template'

provides 'service_template' do
  ::File.exist?('/proc/1/comm') && IO.read('/proc/1/comm').chomp == 'systemd'
end

default_action :create

property :name, String, name_property: true
property :variables, Hash, default: {}

action :create do
  template "/etc/systemd/system/#{new_resource.name}.service" do
    source "#{new_resource.name}.service.erb"
    variables new_resource.variables
  end

  execute 'systemctl daemon-reload'
end
