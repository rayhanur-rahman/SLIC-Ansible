describe 'config-driven-helper::packages' do
  context 'packages are defined' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['packages'] = ["git", "tcpdump"]
      end.converge(described_recipe)
    end

    chef_support = Gem::Dependency.new('chef', '< 12.9').match?('chef', Chef::VERSION)

    it 'will warn that packages recipe needs to be switched to packages-additional' do
      expect{chef_run}.to raise_error
    end unless chef_support

    it 'will install git' do
      expect(chef_run).to install_package('git')
    end if chef_support
  end
end
