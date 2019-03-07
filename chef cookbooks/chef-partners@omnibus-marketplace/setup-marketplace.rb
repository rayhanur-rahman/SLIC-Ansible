%w(/etc/opscode /etc/delivery /etc/chef-marketplace).each do |dir|
  directory dir do
    recursive true
  end
end

file '/etc/chef-marketplace/marketplace.rb' do
  content <<-EOS.gsub(/^\s+/, '')
    role 'automate'
    platform 'aws'
    user 'ec2-user'
    support.email = 'dev@chef.io'
    documentation.url = 'https://docs.chef.io'
    disable_outbound_traffic false
    license.type 'flexible'
    license.free_node_count = 5
    reckoner.product_code = 'DEVENVPRODUCTCODE'
    biscotti.enabled = true
  EOS
end

execute 'chef-marketplace-ctl reconfigure'
