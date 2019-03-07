# Download and extract community templates
dest_path = '/data/templates'

templates = {
  'centos7.qcow2.bz2' => {
    checksum: 'http://dl.openvm.eu/cloudstack/centos/x86_64/centos-7-kvm.qcow2.bz2.sha1sum',
    url: 'http://dl.openvm.eu/cloudstack/centos/x86_64/centos-7-kvm.qcow2.bz2'
  },
  'tiny.qcow2.bz2' => {
    checksum: 'http://dl.openvm.eu/cloudstack/macchinina/x86_64/sha1sum.txt',
    url: 'http://dl.openvm.eu/cloudstack/macchinina/x86_64/macchinina-kvm.qcow2.bz2'
  },
  'systemvm64template-master-4.6.0-kvm.qcow2.bz2' => {
    checksum: 'https://cloudstack.o.auroraobjects.eu/systemvmtemplate/md5sum.txt',
    url: 'https://cloudstack.o.auroraobjects.eu/systemvmtemplate/systemvm64template-master-4.6.0-kvm.qcow2.bz2'
  }
}

# Create base directory for templates
directory dest_path do
  owner 'root'
  group node['bubble']['group_name']
  mode '0775'
  recursive true
  action :create
end

templates.each do |dest_name, urls|
  file "#{dest_path}/#{dest_name}.checksum" do
    action :delete
    not_if { ::File.exist?("#{dest_path}/#{dest_name}") }
  end

  remote_file "#{dest_path}/#{dest_name}.checksum" do
    source "#{urls[:checksum]}"
    mode '0644'
    backup false
    notifies :create, "remote_file[#{dest_path}/#{dest_name}]", :immediately
  end

  remote_file "#{dest_path}/#{dest_name}" do
    source "#{urls[:url]}"
    mode '0644'
    backup false
    notifies :run, "bash[extract_file_#{dest_name}]", :immediately
    action :nothing
  end

  bash "extract_file_#{dest_name}" do
    cwd "#{dest_path}"
    code <<-EOF
    bunzip2 -k -f #{dest_name}
  EOF
    action :nothing
  end
end

jenkins_templates = {
    'cosmic-centos-7.qcow2' => {
        checksum: 'https://beta-jenkins.mcc.schubergphilis.com/job/bubble-templates/job/packer-cron/lastSuccessfulBuild/artifact/cosmic-centos-7/packer_output/cosmic-centos-7.qcow2.md5',
        url: 'https://beta-jenkins.mcc.schubergphilis.com/job/bubble-templates/job/packer-cron/lastSuccessfulBuild/artifact/cosmic-centos-7/packer_output/cosmic-centos-7.qcow2'
    }
}

jenkins_templates.each do |dest_name, urls|
  file "#{dest_path}/#{dest_name}.checksum" do
    action :delete
    not_if { ::File.exist?("#{dest_path}/#{dest_name}") }
  end

  remote_file "#{dest_path}/#{dest_name}.checksum" do
    source "#{urls[:checksum]}"
    mode '0644'
    backup false
    notifies :create, "remote_file[#{dest_path}/#{dest_name}]", :immediately
  end

  remote_file "#{dest_path}/#{dest_name}" do
    source "#{urls[:url]}"
    mode '0644'
    backup false
    action :nothing
  end
end

remote_file "#{dest_path}/#{node['bubble']['systemvm_template']['internal_md5']}" do
  source "#{node['bubble']['systemvm_template']['jenkins_url']}/#{node['bubble']['systemvm_template']['jenkins_md5']}"
  mode '0644'
  backup false
  notifies :run, "ruby_block[download_systemvm_templates]", :immediately
end

ruby_block 'download_systemvm_templates' do
  block do
    File.readlines("#{dest_path}/#{node['bubble']['systemvm_template']['internal_md5']}").map do |line|
      file_extension = "#{line.split('.')[-2]}.gz"

      f = Chef::Resource::File::RemoteFile.new("#{dest_path}/#{node['bubble']['systemvm_template']['name']}.#{file_extension}", run_context)
      f.source "#{node['bubble']['systemvm_template']['jenkins_url']}/#{line.split[1]}"
      f.mode '0644'
      f.backup false
      f.run_action :create

      g = Chef::Resource::Execute.new("extract_gzip_file_#{node['bubble']['systemvm_template']['name']}.#{file_extension}", run_context)
      g.cwd "#{dest_path}"
      g.command "gunzip -f #{node['bubble']['systemvm_template']['name']}.#{file_extension}"
      g.run_action :run
    end
  end
  action :nothing
end
