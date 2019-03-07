group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    site = ConfigDrivenHelper::Util.merge_default_shared_site(node, name, site, server)
    next unless site['protocols'].include?('https')

    group_name = site['ssl']['certfile']
    group_domains[group_name] ||= {domains: [], servers: []}
    group_domains[group_name][:domains] << site['server_name']
    group_domains[group_name][:domains] += site['server_aliases'] if site['server_aliases']
    group_domains[group_name][:ssl] = site['ssl']
    group_domains[group_name][:servers] << server
  end
end

group_domains.each do |group_name, certificate_data|
  subject = certificate_data[:ssl]['subject'] || {}
  subject_hash = {
    "C" => subject['country'],
    "S" => subject['state'],
    "L" => subject['locality'],
    "O" => subject['organisation'],
    "OU" => subject['organisational_unit'],
    "CN" => certificate_data[:domains].first,
  }.select {|k,v| v && !v.empty?}
  directory File.dirname(certificate_data[:ssl]['keyfile']) do
    recursive true
  end
  directory File.dirname(certificate_data[:ssl]['certfile']) do
    recursive true
  end

  execute "Create SSL Certificate for #{group_name}" do
    command "openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 " +
             "-keyout #{certificate_data[:ssl]['keyfile']} " +
             "-out #{certificate_data[:ssl]['certfile']} " +
             "-subj \"/#{subject_hash.map{|k,v| "#{k}=#{v}"}.join('/')}\""
    not_if {
      File.exists?(certificate_data[:ssl]['certfile']) &&
      !File.zero?(certificate_data[:ssl]['certfile'])
    }
    umask 0077

    certificate_data[:servers].uniq.each do |server|
      server = 'apache2' if server == 'apache'
      notifies :reload, "service[#{server}]", :delayed
    end
  end

  file certificate_data[:ssl]['certfile'] do
    mode 0644
  end
end
