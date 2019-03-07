# TODO: This might be better served as a chef-marketplace-ctl command. We might
# want to eventually convert it into a recipe and have a ctl-command to pass
# the attributes to chef run when the process for publishing the Azure template
# has matured.

require "optparse"
require "mixlib/shellout"
require "open-uri"
require "fileutils"

@license = nil
@fqdn = nil

OptionParser.new do |opts|
  opts.on("--fqdn FQDN", String, "The machine FQDN") { |fqdn| @fqdn = fqdn }
  opts.on("--license [LICENSE]", "The Automate license file") do |license|
    @license = license
  end
end.parse!(ARGV)

# Write the Automate license file
if !@license.nil? && !@license.empty?
  license_dir = "/var/opt/delivery/license"
  license_file_path = File.join(license_dir, "delivery.license")

  FileUtils.mkdir_p(license_dir)
  File.write(license_file_path, open(@license, "rb").read)
end

# Append the FQDN to the marketplace config
open("/etc/chef-marketplace/marketplace.rb", "a") do |config|
  config.puts(%Q{api_fqdn "#{@fqdn}"})
end

environment = {
  'HOME' => '/root'
}

# Configure the hostname
hostname = Mixlib::ShellOut.new("chef-marketplace-ctl hostname #{@fqdn}")
hostname.environment = environment
hostname.run_command

# Configure Automate
configure = Mixlib::ShellOut.new("chef-marketplace-ctl setup --preconfigure")
configure.environment = environment
configure.timeout = 1200
configure.run_command
