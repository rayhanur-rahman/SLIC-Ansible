require 'spec_helper'

describe 'enterprise_test::enterprise_pg_user' do
  let(:admin_password) { nil }
  let(:admin_username) { nil }
  let(:host) { nil }
  let(:password) { 'testpass' }
  let(:superuser) { nil }

  let(:runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', step_into: ['enterprise_pg_user']) do |node|
      node.default['testproject']['postgresql']['username'] = 'testuser'
      node.default['test']['admin_password'] = admin_password
      node.default['test']['admin_username'] = admin_username
      node.default['test']['host'] = host
      node.default['test']['password'] = password
      node.default['test']['superuser'] = superuser
    end
  end

  subject(:chef_run) { runner.converge(described_recipe) }

  it 'creates a user' do
    expect(chef_run).to run_execute('create_postgres_user_testuser')
  end

  context 'when a username, host, and password are present' do
    let(:admin_username) { 'testadminuser' }
    let(:admin_password) { 'testadminpass' }
    let(:host) { 'testhost' }

    it 'uses the username, host, and password' do
      expect(chef_run).to run_execute('create_postgres_user_testuser').with(
        command: "psql --dbname template1 --command \"CREATE USER testuser WITH ENCRYPTED PASSWORD 'testpass';\"",
        user: 'testuser',
        retries: 30
      )
    end
  end
end
