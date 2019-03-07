require "marketplace/setup"

add_command_under_category "setup", "Setup", "Set up the Chef Server Marketplace Appliance", 2 do
  options = OpenStruct.new
  options.agree_to_eula = false
  options.register_node = false
  options.preconfigure = false
  options.license_url = nil
  options.license_base64 = nil
  options.debug = false

  OptionParser.new do |opts|
    opts.banner = "Usage: chef-marketplace-ctl setup [options]"

    opts.on("-y", "--yes", "Agree to all setup prompts") do
      options.agree_to_eula = true
      options.register_node = true
    end

    opts.on("--eula", "Agree to the Chef Software End User License Agreement") do
      options.agree_to_eula = true
    end

    opts.on("--register", "Register the node with Chef Software to enable support") do
      options.register_node = true
    end

    opts.on("-u USERNAME", "--username USERNAME", String, "Your Admin username") do |username|
      options.username = username
    end

    opts.on("-p PASSWORD", "--password PASSWORD", String, "Your password") do |password|
      options.password = password
    end

    opts.on("-f FIRSTNAME", "--firstname FIRSTNAME", String, "Your first name") do |first_name|
      options.first_name = first_name
    end

    opts.on("-l LASTNAME", "--lastname LASTNAME", String, "Your last name") do |last_name|
      options.last_name = last_name
    end

    opts.on("-e EMAIL", "--email EMAIL", String, "Your email address") do |email|
      options.email = email
    end

    opts.on("-o ORGNAME", "--org ORGNAME", String, "Your organization name") do |org|
      options.organization = org
    end

    opts.on("--preconfigure", "Preconfigure option used by cloud-init during boot") do
      options.preconfigure = true
    end

    opts.on("--license-url URL", "A URL to a Chef Automate license") do |url|
      options.license_url = url
    end

    opts.on("--license-base64 ENCODED_LICENSE", "A base64 enconded Chef Automate license") do |license|
      options.license_base64 = license
    end

    opts.on("--debug", "Enable debug logging output.") do
      options.debug = true
    end

    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!(ARGV)

  puts "Determining the system hostname.."
  exit(1) unless run_command("chef-marketplace-ctl hostname").exitstatus.to_i == 0

  puts "Starting setup.."
  Marketplace.setup(options, self)
end
