# frozen_string_literal: true
#
# Cookbook Name:: solr_6
# Recipe:: deploy
#
# Copyright (c) 2016 ECHO Inc, All Rights Reserved.

deploy_url = node['solr']['deploy_url']

unless deploy_url
  Chef::Log.fatal('The solr_6::deploy recipe was added to the node,')
  Chef::Log.fatal('but the attribute `node["solr"]["deploy_url"]` was not set.')
  raise 'Required node value not specified'
end

src_filename = ::File.basename(deploy_url)
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"

# Download Solr Core(s) Archive
remote_file src_filepath do
  source deploy_url
  action :create_if_missing
end

# Unpack Downloaded File into the solr_home directory
bash 'unpack_solr_core' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
        su #{node['solr']['user']} -c 'tar -xzf #{src_filename} --directory #{node['solr']['data_dir']}/data'
    EOH
end

# Restart Solr
bash 'restart_solr' do
  code <<-EOH
    service solr restart
  EOH
end
