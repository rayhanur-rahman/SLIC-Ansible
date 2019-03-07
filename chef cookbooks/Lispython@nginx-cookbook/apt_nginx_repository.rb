
# NOTE: This requires the "apt" recipe
case node["platform"]
when "ubuntu"

  # deb http://nginx.org/packages/ubuntu/ codename nginx
  apt_repository "nginx" do
    uri "http://nginx.org/packages/ubuntu/"
    distribution node['lsb']['codename']
    key "nginx_signing.key"
    components ["nginx"]
    action :add
    deb_src true
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end
end
