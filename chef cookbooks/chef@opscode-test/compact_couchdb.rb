#!/usr/bin/ruby

%w(rubygems json).each { |f| require f }

dbs = JSON.parse %x(curl -sS 'http://localhost:5984/_all_dbs')

dbs.each do |db|
  #puts "\n\nrunning compact on #{db}\n"
  %x(curl -X POST -sS 'http://localhost:5984/#{db}/_compact')
  sleep 2
  results = JSON.parse %x(curl -X GET -s 'http://localhost:5984/#{db}')
  #puts "compact_running is #{results["compact_running"]}\n"
  
  while results["compact_running"]
    #puts "not yet captn, #{db} is still running compaction - result was #{results["compact_running"]}\n"
    sleep 2
    results = JSON.parse %x(curl -X GET -s 'http://localhost:5984/#{db}')
    #puts "compact_running is #{results["compact_running"]}\n"
  end
  #puts "okay then, #{db} no longer running compaction - result was '#{results["compact_running"]}'\n"

end
