# Possibly run actions
bash 'delivery-ctl reconfigure' do
  code 'delivery-ctl reconfigure'
  only_if { delivery_configured? }
  action :nothing
end

bash 'delivery-ctl start' do
  code 'delivery-ctl start'
  only_if { delivery_configured? }
  action :nothing
end

# Chef Automate
chef_ingredient 'delivery' do
  action :upgrade
  channel node['chef-marketplace']['update_channel'].to_sym
  notifies :run, 'bash[delivery-ctl reconfigure]', :immediately
  notifies :run, 'bash[yum-clean-all]', :immediately
  notifies :run, 'bash[apt-get-clean]', :immediately
end

bash 'delivery-ctl restart' do
  code 'delivery-ctl restart'
  only_if { delivery_configured? }
end
