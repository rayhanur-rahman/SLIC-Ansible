


FileUtils.cp_r '/root/subhash/source/.', '/root/subhash/destination'







origin = '/root/subhash/destination'
destination = '/root/subhash/source'

Dir.glob(File.join(origin, '*')).each do |file|
  if File.exists? File.join(destination, File.basename(file))
    FileUtils.move file, File.join(destination, "1-#{File.basename(file)}")
  else
    FileUtils.move file, File.join(destination, File.basename(file))
  end
end
