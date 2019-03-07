require 'spec_helper'

describe_recipe 'git::default' do
  context 'when using include_recipe or adding git::default to the run_list' do
    it 'installs git_client[default]' do
      expect(chef_run).to install_git_client('default')
    end
  end
end
