#!/usr/bin/env ruby

# Shuts the system down (via halt) if it's been up for at least 30 minutes and
# there is no 'java slave.jar' process running.

unless File.exists?("/proc/uptime")
  raise "/proc/uptime doesn't exist! This only works on Linux."
end

if File.exists?("/srv/hudson/shutdown-idle-slave.disable")
  exit
end

uptime = 0
File.open("/proc/uptime", "r") do |uptime_file|
  uptime_file.each_line do |line|
    if line =~ /([\d\.]+) ([\d\.]+)/
      uptime = $1.to_f
    end
  end
end

slave_jar_running = false
IO.popen("ps uaxwwww | grep java | grep slave | grep -v grep", "r") do |ps_proc|
  ps_proc.each_line do |line|
    if line =~ /java -jar slave\.jar/
      slave_jar_running = true
    end
  end
end

#puts "slave_jar_running: #{slave_jar_running}"
#puts "uptime: #{uptime}"

if !slave_jar_running && uptime > (30 * 60)
  system '/sbin/halt'
end
