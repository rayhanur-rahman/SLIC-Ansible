require 'spec_helper'

describe 'enterprise::runit' do
  subject(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.normal['enterprise']['name'] = 'testproject'
      node.normal['testproject']['install_path'] = '/opt/testproject'
      node.normal['testproject']['sysvinit_id'] = 'TP'
    end.converge(described_recipe)
  end

  it 'creates a component_runit_supervisor' do
    expect(chef_run).to create_component_runit_supervisor('testproject').with(
      ctl_name: 'testproject-ctl',
      sysvinit_id: 'TP',
      install_path: '/opt/testproject'
    )
  end
end
