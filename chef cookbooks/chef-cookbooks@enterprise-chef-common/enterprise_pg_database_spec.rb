require 'spec_helper'

describe 'enterprise_test::enterprise_pg_database' do
  let(:database) { 'testdb' }
  let(:encoding) { 'UTF-8' }
  let(:host) { nil }
  let(:owner) { nil }
  let(:password) { nil }
  let(:template) { 'template0' }
  let(:username) { nil }

  let(:runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', step_into: ['enterprise_pg_database']) do |node|
      node.default['testproject']['postgresql']['username'] = 'testuser'
      node.default['test']['database'] = database
      node.default['test']['encoding'] = encoding
      node.default['test']['host'] = host
      node.default['test']['owner'] = owner
      node.default['test']['password'] = password
      node.default['test']['template'] = template
      node.default['test']['username'] = username
    end
  end
  subject(:chef_run) { runner.converge(described_recipe) }

  it 'creates a database' do
    expect(chef_run).to run_execute('create_database_testdb')
  end

  context 'when a username, host, and password are present' do
    let(:username) { 'testdbuser' }
    let(:password) { 'testpass' }
    let(:host) { 'testhost' }

    it 'uses the username, host, and password' do
      expect(chef_run).to run_execute('create_database_testdb').with(
        command: 'createdb --template template0 --encoding UTF-8 testdb',
        user: 'testuser',
        retries: 30
      )
    end
  end
end
