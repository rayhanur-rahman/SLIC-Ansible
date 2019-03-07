if node["chef-marketplace"]["role"] =~ /aio|server|automate/
  node.normal["chef-marketplace"]["reckoner"]["usage_dimension"] = "ChefNodes"
elsif node["chef-marketplace"]["role"] == "compliance"
  node.normal["chef-marketplace"]["reckoner"]["usage_dimension"] = "ComplianceNodes"
end

node.normal["chef-marketplace"]["reckoner"]["enabled"] if node["chef-marketplace"]["license"]["type"] == "flexible"
