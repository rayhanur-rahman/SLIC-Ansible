execute 'chef-server-ctl reconfigure' do
  retries 3
end
