resource_name :akzocore_core

action :create do
  # secops=node['solr']['secops']

  bash 'akzocore_core' do
    code <<-EOH
cd /var/solr/data
ls -la | grep secops >> /home/ubuntu/test.txt
if grep -q 'secops' /home/ubuntu/test.txt
 then
     echo 'core is there'

 else
   sudo su - solr -c "/opt/solr/bin/solr create -c secops -n data_driven_schema_configs"

fi

    EOH
  end
end
