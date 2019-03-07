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
# client_name = ARGV[1]

# client_obj = Mixlib::Authorization::Models::Client.on(org_database).by_clientname(:key=>client_name).first
# unless client_obj
#   STDERR.puts "failed to find client #{client_name}"
#   exit 42
# end

# client_id = client_obj["_id"]
# client_auth_id =  Mixlib::Authorization::AuthJoin.by_user_object_id(:key=>client_id).first.auth_object_id
# STDERR.puts "Organization is #{orgname} and the client #{client_name} with client id #{client_id} and auth id #{client_auth_id}"

group_id = Mixlib::Authorization::Models::Group.on(org_database).by_groupname(:key=>"clients").first["_id"]
group_auth_id =  Mixlib::Authorization::AuthJoin.by_user_object_id(:key=>group_id).first.auth_object_id
STDERR.puts "Group 'clients' with id #{group_id} and auth id #{group_auth_id}"

admin_name = Mixlib::Authorization::Models::Group.on(org_database).by_groupname(:key=>"admins").first["actor_and_group_names"]["users"].first
admin_user_id = Mixlib::Authorization::Models::User.by_username(:key=>admin_name).first["_id"]
admin_auth_id =  Mixlib::Authorization::AuthJoin.by_user_object_id(:key=>admin_user_id).first.auth_object_id
STDERR.puts "Organization admin is #{admin_name} with id #{admin_user_id} and auth id #{admin_auth_id}"


clients_auth_group = Mixlib::Authorization::Models::Group.on(org_database).by_groupname(:key=>"clients").first.fetch_join
actor_auth_ids = clients_auth_group["actors"]
group_auth_ids = clients_auth_group["groups"]

group_auth_ids.each do |group_auth_id|
  begin
    auth_join_group = Mixlib::Authorization::AuthJoin.by_auth_object_id(:key=>group_auth_id).first
    if auth_join_group
      puts "group: #{Mixlib::Authorization::Models::Group.on(org_database).get(auth_join_group.user_object_id)["groupname"]}"
    end
  rescue Exception => e
    STDERR.puts "FUCK"    
  end
end

actor_auth_ids.each do |actor_auth_id|
  begin
    auth_join_actor = Mixlib::Authorization::AuthJoin.by_auth_object_id(:key=>actor_auth_id).first
    if auth_join_actor
      puts "client: #{Mixlib::Authorization::Models::Client.on(org_database).get(auth_join_actor.user_object_id)["clientname"]}"
    end
  rescue Exception=>e
    STDERR.puts "FUCK: #{e.inspect}"
  end
end




