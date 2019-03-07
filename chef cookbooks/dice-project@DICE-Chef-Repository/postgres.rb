#
# Cookbook Name:: dice_deployment_service
# Recipe:: postgres
#
# Copyright 2017, XLAB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

db_name = node['dice_deployment_service']['db_name']
dice_user = node['dice_deployment_service']['app_user']

package %w(libpq-dev postgresql postgresql-contrib)

# Next few lines are ugly as hell, but Chef and PostgreSQL is not the best
# match ever to exist.
bash 'Prepare database' do
  user 'postgres'
  code <<-EOC
    psql -c "CREATE DATABASE #{db_name};"
    psql -c "CREATE USER #{dice_user};"
    psql -c "ALTER ROLE #{dice_user} SET client_encoding TO 'utf8';"
    psql -c "ALTER ROLE #{dice_user} SET default_transaction_isolation TO 'read committed';"
    psql -c "ALTER ROLE #{dice_user} SET timezone TO 'UTC';"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE #{db_name} TO #{dice_user};"
    EOC
end
