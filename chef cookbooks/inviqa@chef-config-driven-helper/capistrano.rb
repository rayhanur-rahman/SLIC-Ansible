%w( apache nginx ).each do |type|
  node[type]['sites'].each do |name, site|
    next unless site['capistrano']

    capistrano_app name do
      deploy_to site['capistrano']['deploy_to']
      owner site['capistrano']['owner']
      group site['capistrano']['group']
      mode site['capistrano']['mode']
      shared_folders site['capistrano']['shared_folders']
    end
  end
end
