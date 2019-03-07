#
# Author:: Tim Hinderliter <tim@opscode.com>
# Cookbook Name:: couchdb
# Recipe:: default
#
# Copyright 2010, OpsCode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# If the node's attribute 'clean-couchdb-setup-test' is set to true, then
# shut CouchDB down, nuke its database directory, place pre-canned data
# in its data directory, then restart it. This data is a snapshot of CouchDB
# in a state right after opscode-test's "setup:test" rake task is done.

cpan_module "JSON"

http_request "populate authorization_design_documents" do
  url 'http://localhost:5984/authorization_design_documents/_bulk_docs'
  action :nothing
  message( { "docs" =>
      [{"_id"=>"_design/access_control_entries", "views"=>{"by_acl_and_type"=>{"map"=>"function(doc) { if(doc.type == 'access_control_entry') { emit([doc.acl_id, doc.ace_type],null) } }"}, "by_id"=>{"map"=>"function(doc) { if(doc.type == 'access_control_entry') {emit(doc._id,null)}}"}}}, {"_id"=>"_design/access_control_lists", "views"=>{"by_ace_id"=>{"map"=>"function(doc) { if(doc.type == 'access_control_entry') { emit(doc.acl_id, doc._id) } }"}, "by_id"=>{"map"=>"function(doc) { if(doc.type == 'access_control_list') {emit(doc._id,null)}}"}, "by_object_id"=>{"map"=>"function(doc) { if(doc.type == 'access_control_list') { emit(doc.object_id, doc._id) } }"}}}, {"_id"=>"_design/actors", "views"=>{"by_id"=>{"map"=>"function(doc) { if(doc.type == 'actor') {emit(doc._id,null)}}"}}}, {"_id"=>"_design/containers", "views"=>{"by_path"=>{"map"=>"function(doc) { if(doc.type == 'container') {emit(doc.path,doc._id)}}"}, "by_id"=>{"map"=>"function(doc) { if(doc.type == 'container') {emit(doc._id,null)}}"}}}, {"_id"=>"_design/groups", "views"=>{"by_id"=>{"map"=>"function(doc) { if(doc.type == 'group') {emit(doc._id,null)}}"}}}, {"_id"=>"_design/objects", "views"=>{"by_type"=>{"map"=>"function(doc) {emit(doc._id,doc.type)}"}}}, {"_id"=>"containersets", "couchrest-type"=>"ContainersConfig", "global_containerset"=>{"organizations"=>"organizations", "users"=>"users"}, "organizations_containerset"=>{"groups"=>"groups", "data"=>"data", "search_role"=>"search/role", "cookbooks"=>"cookbooks", "search_node"=>"search/node", "nodes"=>"nodes", "roles"=>"roles", "containers"=>"containers", "search"=>"search", "clients"=>"clients", "sandboxes" => "sandboxes", "environments" => "environments" }}]}
         )
end

# creates authorization_design_documents if it doesn't exist.
http_request "create authorization_design_documents database" do
  url 'http://localhost:5984/authorization_design_documents'
  action :put
  only_if do
    # only create if we get back error, saying it doesn't exist.
    begin
      response = JSON.parse(`curl http://localhost:5984/authorization_design_documents`)
      (response.has_key?("error") && response["error"] == "not_found")
    rescue
      true
    end
  end
  notifies :post, resources(:http_request => "populate authorization_design_documents"), :immediately
end


http_request "clone authorization from authorization_design_documents" do
  # default action is nothing; we will post to this if the authorization database got created.
  url "http://localhost:5984/_replicate"
  action :nothing
  message({:source => "authorization_design_documents", :target => "authorization"})
end

http_request "create authorization database" do
  url "http://localhost:5984/authorization"
  action :put
  only_if do
    # only create if we get back error, saying it doesn't exist.
    begin
      response = JSON.parse(`curl http://localhost:5984/authorization`)
      (response.has_key?("error") && response["error"] == "not_found")
    rescue
      true
    end
  end
  notifies :post, resources(:http_request => "clone authorization from authorization_design_documents"), :immediately
end

