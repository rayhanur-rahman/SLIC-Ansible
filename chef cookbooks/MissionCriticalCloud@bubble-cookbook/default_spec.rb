#
# Cookbook Name:: test-cookbook
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'bubble::default' do
  before(:each) do
    stub_command("which sudo").and_return('/usr/bin/sudo')
  end

  context 'When all attributes are default, on an unspecified platform' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        log_level: :warn,
        platform: 'centos',
        version: '7.1.1503',
        file_cache_path: '/var/chef/cache').converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
