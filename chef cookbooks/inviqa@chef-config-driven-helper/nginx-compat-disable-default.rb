# Default nginx site on CentOS defined here
# And it's hardcoded to listen on port 80
# Problematic if using varnish
file "/etc/nginx/conf.d/default.conf" do
  content ""
  notifies :reload, "service[nginx]"
end unless node["nginx"]["default_site_enabled"]