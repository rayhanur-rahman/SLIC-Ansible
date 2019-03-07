include_recipe "apt"

# add the Zend Server repo
apt_repository "zend-server" do
  uri "http://repos.zend.com/zend-server/7.0/deb_apache2.4"
  distribution "server"
  components ["non-free"]
  key "http://repos.zend.com/zend.key"
  action :add
end