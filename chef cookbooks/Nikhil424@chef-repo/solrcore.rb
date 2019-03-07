resource_name :solrcoretest_solrcore

action :create do
  # secops=node['solr']['secops']

  bash 'solrcoretest_solrcore' do
    code <<-EOH

      cd /var/solr/data
      ls -la | grep secops >> /home/ubuntu/test.txt
      if grep -q 'secops' /home/ubuntu/test.txt 
        then
        echo 'core already created'
      else
        sudo su - solr -c "/opt/solr/bin/solr create -c secops -n data_driven_schema_configs"
      fi
      rm -r /home/ubuntu/test.txt

    EOH
  end
end

