describe 'config-driven-helper::packages-additional' do
  context 'additional packages are defined' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['packages-additional'] = {
          "git" => "install",
          "tcpdump" => "remove"
        }
      end.converge(described_recipe)
    end

    it 'will install git' do
      expect(chef_run).to install_package('git')
    end

    it 'will remove tcpdump' do
      expect(chef_run).to remove_package('tcpdump')
    end
  end

  context 'additional packages are defined using alternative syntax' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['packages-additional'] = {
          "git" => {
            "action" => "install"
          }
        }
      end.converge(described_recipe)
    end

    it 'will install git' do
      expect(chef_run).to install_package('git')
    end
  end
end
