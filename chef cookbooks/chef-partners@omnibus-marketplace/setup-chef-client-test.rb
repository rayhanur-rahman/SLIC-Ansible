require 'cheffish'

# Create a key that we'll use for org, admin user, and client.
private_key '/shared/keys/test.pem' do
  cipher            'DES-EDE3-CBC'
  format            :pem
  public_key_format :openssh
  public_key_path   '/shared/keys/test.pub'
  size              2048
  type              :rsa
end

Chef::Config[:ssl_verify_mode] = :verify_none

# Bootstrap an organization and admin user as pivotal
with_chef_server 'https://127.0.0.1:8443',
  client_name: 'pivotal',
  signing_key_filename: '/etc/opscode/pivotal.pem' do

  chef_user 'test-admin' do
    user_name 'test-admin'
    display_name 'test-admin'
    admin true
    email 'test-admin@chef.io'
    password 'password123!'
    source_key_path '/shared/keys/test.pem'
    retries 3
  end

  chef_organization 'test' do
    full_name 'test'
    retries 3
    members %w(test-admin)
  end

  chef_acl '/organizations/test/containers/clients' do
    rights :all, users: 'test-admin'
  end
end

# Bootstrap a client as the admin user
with_chef_server 'https://127.0.0.1/organizations/test',
  client_name: 'test-admin',
  signing_key_filename: '/shared/keys/test.pem' do

  chef_client 'test-node' do
    source_key_path '/shared/keys/test.pem'
    retries 3
  end
end

# Bootstrap a node as the client
with_chef_server 'https://127.0.0.1/organizations/test',
  client_name: 'test-node',
  signing_key_filename: '/shared/keys/test.pem' do

  chef_node 'test-node' do
    run_list %w(audit)
    attributes(
      'audit' => {
        'reporter' => 'chef-server-automate',
        'fetcher' => 'chef-server',
        'inspec_version' => '1.33.1',
        'profiles' => [
          { 'name' => 'linux-baseline', 'url' => 'https://github.com/dev-sec/linux-baseline/archive/2.1.0.zip' },
          { 'name' => 'linux-patch-baseline', 'compliance' => 'test/linux-patch-baseline' },
        ],
      }
    )
  end
end

directory '/root/.chef' do
  recursive true
end

file '/root/.chef/knife.rb' do
  content <<-EOS.gsub(/^\s+/, '')
    log_location     STDOUT
    chef_server_url  'https://automate-marketplace.test/organizations/test'
    node_name        'test-admin'
    ssl_verify_mode  :verify_none
    client_key       '/shared/keys/test.pem'
  EOS
end

file '/etc/chef/Berksfile' do
  content <<-EOS.gsub(/^\s+/, '')
    source "https://supermarket.chef.io"

    cookbook "audit", ">= 4.1.1"
  EOS
end

bash 'upload-cookbooks' do
  code <<-EOS.gsub(/^\s+/, '')
    berks install -b /etc/chef/Berksfile
    berks upload --no-ssl-verify -b /etc/chef/Berksfile
  EOS

  live_stream true
end

directory "/var/opt/delivery/compliance/profiles/test" do
  owner "delivery"
  group "delivery"
  recursive true
end

remote_file "/var/opt/delivery/compliance/profiles/test/linux-patch-baseline-0.3.0.tar.gz" do
  owner "delivery"
  group "delivery"
  source "file:///shared/files/linux-patch-baseline-0.3.0.tar.gz"
end
