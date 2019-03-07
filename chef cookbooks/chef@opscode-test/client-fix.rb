#!/usr/bin/env ruby

require 'rubygems'
require 'couchrest'
require 'chef/log'

couchdb_uri = 'localhost:5984'
couchrest = CouchRest.new(couchdb_uri)
couchrest.database!('opscode_account')
couchrest.default_database = 'opscode_account'

require 'mixlib/authorization'
Mixlib::Authorization::Config.couchdb_uri = couchdb_uri
Mixlib::Authorization::Config.default_database = couchrest.default_database
Mixlib::Authorization::Config.authorization_service_uri = 'http://localhost:5959'
Mixlib::Authorization::Config.certificate_service_uri = "http://localhost:5140/certificates"
require 'mixlib/authorization/auth_join'
require 'mixlib/authorization/models'

Mixlib::Authorization::Log.level = :fatal
Mixlib::Authentication::Log.level = :fatal
Chef::Log.level = :fatal

include Mixlib::Authorization::AuthHelper

orgname = ARGV[0]
org_database = database_from_orgname(orgname)


Mixlib::Authorization::Models::Client.on(org_database).all.each do |client|
  client = Mixlib::Authorization::Models::Client.on(org_database).new(client)
  acl = Mixlib::Authorization::AuthAcl.new(client.fetch_join_acl).to_user(org_database)
  puts "========================="
  puts "client: #{client["clientname"]}"
  puts acl.inspect
  puts "========================="  
end
