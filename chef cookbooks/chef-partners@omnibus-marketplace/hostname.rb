require "marketplace/hostname"

add_command_under_category "hostname", "Configuration", "Query and modify the hostname", 2 do
  @eip = false
  marketplace = Marketplace::Hostname.new
  user_args = ARGV[3..-1] || []
  # Switches start with a dash but our hostname shouldn't..
  hostname = user_args.find { |a| a !~ /^\-/ }

  OptionParser.new do |opts|
    opts.banner = "Usage: chef-marketplace-ctl hostname [HOSTNAME] [options]"

    opts.on("-e", "--associate-eip", "Associate an Elastic IP Address") do
      @eip = true
    end

    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!(ARGV)

  if @eip
    puts "ERROR: You must provide a hostname when associating an EIP" && exit(1) unless hostname
    marketplace.associate_eip(hostname)
  end

  if hostname
    puts "Configuring the hostname to: #{hostname}.."

    marketplace.write_chef_json("/opt/chef-marketplace/embedded/cookbooks/update-hostname.json", hostname)
    run_chef("/opt/chef-marketplace/embedded/cookbooks/update-hostname.json")

    puts "Reconfiguring Chef Server software..."
    run_command("chef-marketplace-ctl reconfigure")
    if server_configured?
      run_command("chef-server-ctl reconfigure")
      run_command("opscode-reporting-ctl reconfigure")
    end
    run_command("opscode-manage-ctl reconfigure") if manage_configured?
    run_command("opscode-analytics-ctl reconfigure") if analytics_configured?
    run_command("automate-ctl reconfigure") if automate_configured?
  else
    fqdn = marketplace.resolve
    msg = "ERROR: The Chef Server requires a resolvable fully qualified domain name."
    msg << "You can attempt to associate a FQDN by running: chef-marketplace-ctl hostname your.hostname.com"
    puts msg && exit(1) unless fqdn
    puts fqdn
  end
  exit(0)
end

def server_configured?
  File.exist?("/etc/opscode/chef-server-running.json")
end

def analytics_configured?
  File.exist?("/etc/opscode-analytics/opscode-analytics-running.json")
end

def manage_configured?
  File.exist?("/etc/opscode-manage/opscode-manage-running.json")
end

def automate_configured?
  File.exist?("/etc/delivery/delivery-running.json")
end
