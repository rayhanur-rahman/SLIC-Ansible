require 'spec_helper'

describe 'device-mapper::package' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
