resource_name :akzo_backup

action :create do

bash 'akzo_backup' do
code <<-EOH

sudo su -
cd /root/subhash/source
mv -t /root/subhash/destination file1.rb file2.rb 
cd ~
 cd /root/subhash/destination/
mv file1.rb file2.rb /root/subhash/source/


EOH
end

end



