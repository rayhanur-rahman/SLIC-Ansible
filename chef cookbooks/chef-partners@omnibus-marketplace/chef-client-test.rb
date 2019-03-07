directory '/etc/chef' do
  recursive true
end

file '/etc/chef/client.rb' do
  content <<-EOS.gsub(/^\s+/, '')
    log_location     STDOUT
    chef_server_url  'https://automate-marketplace.test/organizations/test'
    node_name        'test-node'
    ssl_verify_mode  :verify_none
    client_key       '/shared/keys/test.pem'
  EOS
end

execute 'chef-client' do
  live_stream true
end
