describe 'config-driven-helper::capistrano' do
  context 'with apache site configuration' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['apache']['sites']['inviqa'] = {
          'capistrano' => {
            'deploy_to' => '/var/www/sites/inviqa.com',
            'owner' => 'deploy',
            'group' => 'deploy',
            'shared_folders' => {
              'readable' => {
                'folders' => [
                  'app'
                ]
              },
              'writeable' => {
                'owner' => 'apache',
                'group' => 'apache',
                'folders' => [
                  'uploads',
                  'app/./cache/disk'
                ]
              }
            }
          }
        }
      end.converge(described_recipe)
    end

    it "creates releases and shared directories" do
      %w( releases shared ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/#{folder}").with(
          owner: 'deploy',
          group: 'deploy',
          mode: '0775',
        )
      end
    end

    it "creates readable directories with inherited permissions" do
      %w( app ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/shared/#{folder}").with(
          owner: 'deploy',
          group: 'deploy',
          mode: '0775',
        )
      end
    end

    it "creates writeable directories with apache permissions" do
      %w( app/./cache app/./cache/disk uploads ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/shared/#{folder}").with(
          owner: 'apache',
          group: 'apache',
          mode: '0775',
        )
      end
    end
  end

  context 'with nginx site configuration' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['inviqa'] = {
          'capistrano' => {
            'deploy_to' => '/var/www/sites/inviqa.com',
            'owner' => 'deploy',
            'group' => 'deploy',
          }
        }
      end.converge(described_recipe)
    end

    it "creates releases and shared directories" do
      %w( releases shared ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/#{folder}").with(
          owner: 'deploy',
          group: 'deploy',
          mode: '0775',
        )
      end
    end
  end

  context 'with custom mode configuration' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['inviqa'] = {
          'capistrano' => {
            'deploy_to' => '/var/www/sites/inviqa.com',
            'owner' => 'deploy',
            'group' => 'deploy',
            'mode' => '0711',
            'shared_folders' => {
              'readable' => {
                'folders' => [
                  'app'
                ]
              },
              'writeable' => {
                'owner' => 'apache',
                'group' => 'apache',
                'mode' => '0771',
                'folders' => [
                  'uploads',
                  'app/./cache/disk'
                ]
              }
            }
          }
        }
      end.converge(described_recipe)
    end

    it "creates base directories with custom mode" do
      %w( releases shared ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/#{folder}").with(
          mode: '0711',
        )
      end
    end

    it "creates shared folders with inherited mode" do
      %w( app ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/shared/#{folder}").with(
          mode: '0711',
        )
      end
    end

    it "creates shared folders with custom mode" do
      %w( uploads ).each do |folder|
        expect(chef_run).to create_directory("/var/www/sites/inviqa.com/shared/#{folder}").with(
          mode: '0771',
        )
      end
    end
  end
end
