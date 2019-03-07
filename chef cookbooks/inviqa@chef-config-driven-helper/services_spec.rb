describe 'config-driven-helper::services' do
  context 'with two services' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['services'] = {
          'test1' => ['start', 'enable'],
          'test2' => ['stop', 'disable']
        }
      end.converge(described_recipe)
    end

    it 'will start test1 via delayed notification' # do
#      expect(chef_run.ruby_block('service control (test1)')).to subscribe_to('service[test1]').on(:run).delayed
#    end

    it 'will start test2 via delayed notification' # do
#      expect(chef_run.ruby_block('service control (test2)')).to subscribe_to('service[test2]').on(:run).delayed
#    end

    it 'will ensure the test1 ruby block is triggered via a log message' do
      expect(chef_run.log('service control (test1)')).to notify('ruby_block[service control (test1)]').to(:run).delayed
    end

    it 'will ensure the test2 ruby block is triggered via a log message' do
      expect(chef_run.log('service control (test2)')).to notify('ruby_block[service control (test2)]').to(:run).delayed
    end
  end
end
