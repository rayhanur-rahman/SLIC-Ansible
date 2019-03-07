require 'spec_helper'

# examples at https://github.com/sethvargo/chefspec/tree/master/examples

describe 'apache2::default' do
  platforms = {
    'ubuntu' => ['12.04'],
    'debian' => ['7.0'],
    'centos' => ['5.9', '6.4']
  }

  # Test all generic stuff on all platforms
  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(:platform => platform, :version => version) do |node|
          end.converge('apache2::default')
        end

      end
    end
  end
end
