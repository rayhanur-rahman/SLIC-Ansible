nginx Mash.new unless attribute?("nginx")

set_unless[:nginx][:version] = "0.8.33-patched" 
nginx[:dir]     = "/etc/nginx"
nginx[:log_dir] = "/srv/nginx/log"
nginx[:user]    = "www-data"
nginx[:install_path]  = "/srv/nginx/#{nginx[:version]}"
nginx[:binary]  = "/srv/nginx/#{nginx[:version]}/sbin/nginx"

nginx[:gzip] = "on"               unless attribute?("nginx_gzip")
nginx[:gzip_http_version] = "1.0" unless attribute?("nginx_gzip_http_version")
nginx[:gzip_comp_level] = "2"     unless attribute?("nginx_gzip_comp_level")
nginx[:gzip_proxied] = "any"      unless attribute?("nginx_gzip_proxied")
nginx[:gzip_types] = [ "text/plain", "text/html", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript" ] unless attribute?("nginx_gzip_types")

nginx[:keepalive] = "on"       unless attribute?("nginx_keepalive")
nginx[:keepalive_timeout] = 65 unless attribute?("nginx_keepalive_timeout")

nginx[:worker_processes] = cpu[:total] 
nginx[:worker_connections] = 4096 
nginx[:server_names_hash_bucket_size] = 64 unless attribute?("nginx_server_names_hash_bucket_size")

