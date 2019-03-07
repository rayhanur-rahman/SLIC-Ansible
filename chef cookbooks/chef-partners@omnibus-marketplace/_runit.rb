include_recipe "enterprise::runit"

usr = grp = node["chef-marketplace"]["runit"]["user"]["username"]

user usr do
  system true
  shell node["chef-marketplace"]["runit"]["user"]["shell"]
  home node["chef-marketplace"]["runit"]["user"]["home"]
end

group grp do
  members [usr]
end

directory "/var/opt/chef-marketplace" do
  recursive true
  owner usr
  group grp
  mode "0775"
end

directory "/var/log/chef-marketplace" do
  recursive true
  owner usr
  group grp
  mode "0775"
end
