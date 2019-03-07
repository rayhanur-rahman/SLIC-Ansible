require "ohai"

add_command_under_category "show-instance-id", "Configuration", "Show the cloud instance ID. Required for first time setup authorization.", 2 do
  puts "Looking up current Instance ID..."

  instance = Ohai::System.new.all_plugins

  result = case instance[:cloud][:provider]
           when 'azure'
             instance[:azure][:metadata][:compute][:vmId]
           when 'ec2'
             instance[:ec2][:instance_id]
           when nil, ""
             "Unable to detect the current cloud provider."
           else
             "Unsupported cloud provider #{instance[:cloud][:provider]}"
           end

  puts result
end
