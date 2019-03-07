if File.exist?("/etc/chef-compliance/chef-compliance-running.json")
  compliance = JSON.parse(IO.read("/etc/chef-compliance/chef-compliance-running.json"))
  node.consume_attributes("chef-compliance" => compliance["chef-compliance"])
end
