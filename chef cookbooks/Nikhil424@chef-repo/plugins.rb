resource_name :pluginjenkins_plugins

action :install do

  jenkins_plugin 'github' do
    install_deps true
    notifies :restart, 'runit_service[jenkins]', :immediately
  end

  jenkins_plugin 'buildresult-trigger' do
    install_deps true
    notifies :restart, 'runit_service[jenkins]', :immediately
  end

  jenkins_plugin 'workflow-step-api' do
    version '2.9'
    install_deps true
    notifies :restart, 'runit_service[jenkins]', :immediately
  end

  jenkins_plugin 'artifactory' do
    install_deps true
    notifies :restart, 'runit_service[jenkins]', :immediately
  end

end

action :uninstall do

  jenkins_plugin 'github' do
    action :uninstall
  end

  jenkins_plugin 'buildresult-trigger' do
    action :uninstall
  end

  jenkins_plugin 'artifactory' do
    action :uninstall
  end

end
