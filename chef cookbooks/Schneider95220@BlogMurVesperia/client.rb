include_recipe "mariadb::repository"

package "mariadb-client" do
    action :install
end