#!/usr/bin/env ruby

# Compensate for the timestamp delta between an NFS server hosting files 
# and the local time. 
#
# This is required as our NFS server isn't running NTP update, and is sometimes 
# many seconds off of the Hudson VM and the slave builder VM. If all the 
# machines are running an NTP updater then this script isn't required.
#
# The root issue is that Hudson won't accept JUnit XML output files if they are 
# over a certain number of seconds old.
#
# For some reason, Linux 'touch' shows this behavior, but Ruby's touch (through 
# "File.utime") updates with the correct system time (as opposed to the NFS 
# server time). So, we're just going to update each of the input files to the
# current time.

$now = Time.now

def touch_file(filename)
  #puts "touch_file: #{filename}"
  File.utime($now, $now, filename)
end

ARGV.each do |filename|
  if File.directory?(filename)
    Dir["#{filename}/*"].each do |filename_in_dir|
      touch_file(filename_in_dir)
    end
  else
    touch_file(filename)
  end
end

  

  

  
  