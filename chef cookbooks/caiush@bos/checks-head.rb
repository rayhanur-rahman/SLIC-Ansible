include_recipe "bcpc::checks-common"

 %w{ rgw mysql }.each do |cc|
   template  "/usr/local/etc/checks/#{cc}.yml" do
     source "checks/#{cc}.yml.erb"
     owner "root"
     group "root"
     mode 00640
   end

   cookbook_file "/usr/local/bin/checks/#{cc}" do
     source "checks/#{cc}"
     owner "root"
     mode "00755"
   end
 end

