rsource_name :artifactory_create

action_class do

  bash 'artifactory_create' do
    code <<-EOH

      sudo apt-get install unzip
      wget -r https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-4.7.7.zip
      cd /home/ubuntu/bintray.com/jfrog/artifactory
      mv download* /home/ubuntu/
      cd /home/ubuntu/
      unzip download*
      sudo cp /opt/artifactory-oss-4.7.7/webapps/artifactory.war /opt/artifactory-oss-4.7.7/tomcat/webapps

    EOH
  end
end

