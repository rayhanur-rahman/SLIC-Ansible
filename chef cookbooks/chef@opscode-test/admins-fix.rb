#!/usr/bin/env ruby

require 'rubygems'
require 'couchrest'
require 'chef/log'

couchdb_uri = ARGV[0] #'localhost:5984'
couchrest = CouchRest.new(couchdb_uri)
couchrest.database!('opscode_account')
couchrest.default_database = 'opscode_account'

require 'mixlib/authorization'
Mixlib::Authorization::Config.couchdb_uri = couchdb_uri
Mixlib::Authorization::Config.default_database = couchrest.default_database
Mixlib::Authorization::Config.authorization_service_uri = ARGV[1] #'http://localhost:5959'
Mixlib::Authorization::Config.certificate_service_uri = "http://localhost:5140/certificates"
require 'mixlib/authorization/auth_join'
require 'mixlib/authorization/models'

Mixlib::Authorization::Log.level = :debug
Mixlib::Authentication::Log.level = :fatal
Chef::Log.level = :fatal

include Mixlib::Authorization::AuthHelper

orgs = Mixlib::Authorization::Models::Organization.all

orgs.each do |org|
  orgname = org["name"]

  org_database = database_from_orgname(orgname)

  puts "========================="
  group = Mixlib::Authorization::Models::Group.on(org_database).by_groupname(:key=>"admins").first
  
  puts group.inspect
  user = group["actor_and_group_names"]["users"].first
  acl = Mixlib::Authorization::AuthAcl.new(group.fetch_join_acl)
  puts acl.inspect
#   ["read","delete","update"].each do |ace|
#     user_ace = acl.aces[ace].to_user(org_database)
#     user_ace.add_actor(user)
#     group.update_join_ace(ace, user_ace.to_auth(org_database).ace)
#   end
#   puts Mixlib::Authorization::Models::Group.on(org_database).new(group).save
  puts "========================="
end

