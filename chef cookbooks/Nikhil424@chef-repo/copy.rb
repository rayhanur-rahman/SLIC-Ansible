file "/root/subhash/destination/file1.rb" do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open("/root/subhash/source/file1.rb").read
  action :create
end
