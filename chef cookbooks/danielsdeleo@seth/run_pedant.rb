#!/usr/bin/env ruby
require 'bundler'
require 'bundler/setup'
require 'seth_zero/server'
require 'rspec/core'
require 'seth/seth_fs/seth_fs_data_store'
require 'seth/seth_fs/config'
require 'tmpdir'
require 'fileutils'
require 'seth/version'

def start_server(seth_repo_path)
  Dir.mkdir(seth_repo_path) if !File.exists?(seth_repo_path)

  # 11.6 and below had a bug where it couldn't create the repo children automatically
  if Seth::VERSION.to_f < 11.8
    %w(clients cookbooks data_bags environments nodes roles users).each do |child|
      Dir.mkdir("#{seth_repo_path}/#{child}") if !File.exists?("#{seth_repo_path}/#{child}")
    end
  end

  # Start the new server
  Seth::Config.repo_mode = 'everything'
  Seth::Config.seth_repo_path = seth_repo_path
  Seth::Config.versioned_cookbooks = true
  seth_fs = Seth::sethFS::Config.new.local_fs
  data_store = Seth::sethFS::sethFSDataStore.new(seth_fs)
  data_store = SethZero::DataStore::V1ToV2Adapter.new(data_store, 'seth', :org_defaults => sethZero::DataStore::V1ToV2Adapter::ORG_DEFAULTS)
  server = SethZero::Server.new(:port => 8889, :data_store => data_store)#, :log_level => :debug)
  server.start_background
  server
end

tmpdir = Dir.mktmpdir
begin
  # Create seth repository
  seth_repo_path = "#{tmpdir}/repo"

  # Capture setup data into master_seth_repo_path
  server = start_server(seth_repo_path)

  require 'pedant'
  require 'pedant/opensource'

  #Pedant::Config.rerun = true

  Pedant.config.suite = 'api'
  Pedant.config[:config_file] = 'spec/support/pedant/pedant_config.rb'
  Pedant.setup([
    '--skip-ceth',
    '--skip-validation',
    '--skip-authentication',
    '--skip-authorization',
    '--skip-omnibus'
  ])

  result = RSpec::Core::Runner.run(Pedant.config.rspec_args)

  server.stop if server.running?
ensure
  FileUtils.remove_entry_secure(tmpdir) if tmpdir
end

exit(result)
