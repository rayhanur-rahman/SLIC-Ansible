case node["platform"]
when "redhat"
  bash "subscription-manager repos --enable rhel-7-server-rh-common-rpms" do
    code "subscription-manager repos --enable rhel-7-server-rh-common-rpms"
    not_if "subscription-manager repos --list-enabled | grep rhel-7-server-rh-common-rpms"
    only_if "subscription-manager repos --list | grep rhel-7-server-rh-common-rpms"
  end
when "centos"
  %w{base extras plus updates}.each do |repo|
    node.normal["yum"][repo]["enabled"] = true
    node.normal["yum"][repo]["managed"] = true
  end

  include_recipe "yum-centos::default"
end
