include_recipe 'users'

users_manage node['bubble']['group_name'] do
  data_bag node['bubble']['users_databag']
  action [:remove, :create]
end
