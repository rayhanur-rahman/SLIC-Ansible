#!/usr/bin/env ruby
require 'rubygems'
require 'pp'
require 'chef'
require 'tempfile'
 
PREFIX="slamd"
 
Chef::Config[:http_retry_count] = 3
Chef::Config[:rest_timeout] = 300
 
Chef::Config[:log_level]      =  :fatal
Chef::Config[:log_location]   =  STDOUT
Chef::Config[:validation_client_name]      =  'dan-org-validator'
Chef::Config[:validation_key]     =  '/Users/ddeleo/bb/dan-org-validator.pem'
Chef::Config[:chef_server_url] =  'https://api-dev.opscode.com/organizations/dan-org'  
Chef::Config[:cache_type]      = 'BasicFile'
Chef::Config[:cache_options]   = { :path => '/Users/ddeleo/.chef/checksums' }
 
 
unless ARGV.first
  puts "usage concurrency-slammer.rb NUMBER_OF_THREADS"
  exit 127
end
 
concurrency_level = ARGV.first.to_i
 
threads = {}
clients = {}
client_attempts = []
 
concurrency_level.times do
  thread_tag = UUIDTools::UUID.random_create.to_s
  threads[thread_tag] = Thread.new do
    # Client Creation Step
    begin
      #puts "creating client '#{PREFIX}-#{thread_tag}'"
      client_attempts << "#{PREFIX}-#{thread_tag}"
      c = Chef::ApiClient.new
      c.name("#{PREFIX}-#{thread_tag}")
      response = c.save(true, true)
      clients["#{PREFIX}-#{thread_tag}"] = response
      puts "### client creation success (#{thread_tag})"
    rescue Exception => e
      puts( '#' + ('=' * 79))
      puts "# client creation failed (#{thread_tag}) with error:"
      puts "# " + e.inspect
      puts('#' + ('=' * 79))
    end
  end
end
 
pp({"concurrency_level" => concurrency_level})
pp({"clients-to-create" => client_attempts})
 
# Spin until all the client creation has finished
threads.values.each {|t| t.join }
 
pp({"client_success_count" => clients.keys.size})
pp({"successful_clients" => clients.keys})
 
successful_nodes = []
failed_nodes = {}
 
clients.each do |client_name, client_properties|
  begin
    puts "## Attempting to create node '#{client_name}'"
 
    keyfile = Tempfile.open("keyfile-#{client_name}.pem", "/tmp")
    keyfile.write(client_properties["private_key"].strip)
    keyfile.flush
    keyfile.close
 
    Chef::Config[:client_key] = keyfile.path
    Chef::Config[:node_name] = client_name
 
    #puts "BUGBUG #{keyfile.path}"
    #puts "BUGBUG #{IO.read(keyfile.path)} BUGBUG"
 
    node = Chef::Node.new
    node.name(client_name)
    node.save
    
    successful_nodes << client_name
    puts "# node creation success (#{client_name})"
  rescue Exception => e
    failed_nodes[client_name] = client_properties
    puts '#' + ('=' * 79)
    puts "### Failed to Create Node: #{client_name}"
    puts '# ' + e.inspect
    pp e.backtrace
    puts '#' + ('=' * 80)
  ensure
    keyfile.close
    File.unlink(keyfile.path)
  end
end
 
puts '#' + ('=' * 79)
puts '# REPORT '
puts '#' + ('=' * 79)
 
 
pp({"successful_node_count" => successful_nodes.size})
pp({"successful_nodes" => successful_nodes})
 
puts
puts '#' + ('=' * 79)
puts
 
pp({"failed_node_count" => failed_nodes.size})
pp({"failed_nodes" => failed_nodes})

