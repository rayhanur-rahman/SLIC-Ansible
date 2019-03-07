require 'spec_helper'

describe 'config-driven-helper::apache-sites' do
  before do
    stub_command("/usr/sbin/apache2 -t").and_return(true)
  end

  context 'with an apache site' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['apache']['sites']['hello.example.com']['docroot'] = '/var/www/hello.example.com'
        node.set['apache']['sites']['hello.example.com']['server_name'] = 'hello.example.com'
        node.set['apache']['sites']['hello.example.com']['allow_from'] = ['127.0.0.1']
        node.set['apache']['version'] = '2.4'
      end.converge(described_recipe)
    end

    it 'will write out a hello.example.com vhost' do
      expect(chef_run).to create_template('/etc/apache2/sites-available/hello.example.com.conf')
    end

    it 'will write out apache configuration' do
      expect(chef_run).to render_file('/etc/apache2/sites-available/hello.example.com.conf')
        .with_content('Require ip 127.0.0.1')
    end

    it 'will not write out apache configuration' do
      expect(chef_run).to_not render_file('/etc/apache2/sites-available/hello.example.com.conf')
        .with_content('Allow from 127.0.0.1')
    end
  end
end
