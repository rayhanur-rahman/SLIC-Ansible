default['nginx']['sites'] = {}
default['apache']['sites'] = {}

default['ssl_certs'] = {}
default['packages-additional'] = {}

default['nginx']['https_variable_emulation'] = false
default['nginx']['real_ip_header'] = "X-Forwarded-For"
default['nginx']['real_ip_from'] = [] 
default['nginx']['real_ip_recursive'] = "On"

protocols = {
  'nginx' => 'TLSv1 TLSv1.1 TLSv1.2',
  'apache' => 'All -SSLv2 -SSLv3'
}

['apache', 'nginx'].each do |type|
  site = node.default["#{type}-sites"]

  site['secure_port'] = 443
  site['insecure_port'] = 80
  site['endpoint'] = 'index.php'
  site['php_support'] = true
  site['realpath_document_root'] = false
  site['request_header_proxy_hide'] = true
  site['http_auth']['type'] = 'none'
  site['http_auth']['file'] = nil
  site['http_auth']['realm'] = 'Protected System'
  site['php-fpm']['host'] = '127.0.0.1'
  site['php-fpm']['port'] = 9000
  site['php-fpm']['socket'] = '/var/run/php-fpm-www.sock'
  site['php-fpm']['listen'] = 'socket'
  site['probe_url'] = '/LICENSE.txt' # legacy default value
  site['ssl']['certfile'] = '/etc/pki/tls/certs/cert.pem'
  site['ssl']['keyfile'] = '/etc/pki/tls/private/key.pem'
  site['ssl']['protocols'] = protocols[type]
  site['ssl']['ciphersuites_available'] = {
    'noweak' => '!aNULL:!MD5:!DSS',
    'rsa' => 'RSA+AESGCM:RSA+AES',
    'strong' => 'ECDH+ECDSA+AESGCM:ECDH+aRSA+AESGCM:DH+AESGCM:ECDH+ECDSA+AES256:ECDH+aRSA+AES256:DH+AES256:ECDH+ECDSA+AES128:ECDH+aRSA+AES128:DH+AES',
    'sweet32' => 'ECDH+3DES:DH+3DES:RSA+3DES'
  }
  site['ssl']['ciphersuites'] = [
    'strong',
    'noweak'
  ]
  site['ssl']['cacertfile'] = nil
  site['ssl']['certchainfile'] = nil
  site['template'] = "#{type}_site.conf.erb"
  site['cookbook'] = 'config-driven-helper'
  site['protocols'] = ['http']
  site['forwarded_proto_https_emulation'] = false
  site['enable_http2_tls'] = false
  site['enable_http2_plaintext_disabling_http1'] = false
  site['server_type'] = type
  site['disable_default_location_block'] = false
end

default['iptables-standard']['allowed_incoming_ports'] = {
  "http" => "http",
  "https" => "https",
  "ssh" => "ssh"
}

default['mysql']['connections']['default'] = {
  :username => "root",
  :password => node["mysql"]["server_root_password"],
  :host => "localhost"
}
