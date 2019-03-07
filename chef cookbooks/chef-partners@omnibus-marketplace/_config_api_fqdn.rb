# Configure the Chef Server/Compliance FQDN
#   1) Use the value set in marketplace.rb
#   2) Use the cloud public hostname
#   3) Use the cloud local hostname
#   4) Fallback on the FQDN

return if node["chef-marketplace"]["api_fqdn"]

node.normal["chef-marketplace"]["api_fqdn"] =
  if node.key?("cloud_v2") && !node["cloud_v2"].nil?
    if node["cloud_v2"]["provider"] == "gce"
      node["cloud_v2"]["public_ipv4"] if node["cloud_v2"]["public_ipv4"] && !node["cloud_v2"]["public_ipv4"].empty?
    elsif node["cloud_v2"]["public_hostname"] && !node["cloud_v2"]["public_hostname"].empty?
      node["cloud_v2"]["public_hostname"]
    elsif node["cloud_v2"]["local_hostname"] && !node["cloud_v2"]["local_hostname"].empty?
      node["cloud_v2"]["local_hostname"]
    end
  end

node.override["chef-marketplace"]["api_fqdn"] = node["fqdn"] unless node["chef-marketplace"]["api_fqdn"] && !node["chef-marketplace"]["api_fqdn"].empty?
