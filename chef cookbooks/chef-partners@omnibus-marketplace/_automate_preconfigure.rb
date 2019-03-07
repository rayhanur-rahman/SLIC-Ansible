server_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

server_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end

automate_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

automate_state_directories.each do |state_dir|
  directory state_dir do
    action :delete
    recursive true
  end
end

marketplace_state_files.each do |state_file|
  file state_file do
    action :delete
  end
end

bash "recreate server and add on runit directories" do
  code "mkdir -p /opt/{opscode,delivery}/{sv,init,service}"
end
