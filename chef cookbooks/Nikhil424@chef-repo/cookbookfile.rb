cookbook_file '/root/subhash/destination/new.rb' do
  source 'new.rb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
