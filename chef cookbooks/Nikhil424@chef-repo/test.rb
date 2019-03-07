resource_name :jenkinsuser_test

action :remove do

  execute 'This is to remove initial setup wizard in jenkins' do
    command 'sudo service jenkins stop'
    cwd '/var/lib/jenkins/'
    user 'root'
  end
	
  execute 'This is to remove initial setup wizard in jenkins' do
    command 'sudo nohup java -Djenkins.install.runSetupWizard=false -jar jenkins.war &'
    cwd '/var/lib/jenkins/'
    user 'root'
  end

end
