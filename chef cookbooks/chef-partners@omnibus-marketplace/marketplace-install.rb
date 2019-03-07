require 'mixlib/install'

marketplace_version = ENV['VERSION'] == 'latest' ? :latest : ENV['VERSION']

[
  {
    'product_name' => 'marketplace',
    'channel' => ENV['CHANNEL'],
    'version' => marketplace_version,
    'package_name' => 'chef-marketplace'
  },
  {
    'product_name' => 'automate',
    'channel' => ENV['CA_CHANNEL'],
    'version' => :latest,
    'package_name' => 'delivery'
  },
  {
    'product_name' => 'chef-server',
    'channel' => ENV['CS_CHANNEL'],
    'version' => :latest,
    'package_name' => 'chef-server-core'
  }
].each do |product|
  if product['channel'] == 'local' # only supported for marketplace when running locally
    most_recent_build = Dir['/omnibus-pkgs/*.deb'].sort do |a, b|
      File.new(a).mtime <=> File.new(b).mtime
    end.last

    dpkg_package product['package_name'] do
      source most_recent_build
      action :install
    end
  else
    options = {
      channel: product['channel'].to_sym,
      product_name: product['product_name'],
      platform: 'ubuntu',
      platform_version: '14.04',
      architecture: 'x86_64'
    }
    options['product_version'] = product['version'] if product['version']

    artifact = Mixlib::Install.new(options).artifact_info

    remote_file "/shared/packages/#{product['package_name']}-#{artifact.version}.deb" do
      source artifact.url
    end

    dpkg_package product['package_name'] do
      source "/shared/packages/#{product['package_name']}-#{artifact.version}.deb"
      action :install
    end
  end
end
