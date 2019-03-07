require "marketplace/actions_trimmer"

add_command_under_category "trim-actions-db", "Maintenance", "Trim the Chef Analytics actions database", 2 do
  @options = { db_size: 1, interval: 4 }

  OptionParser.new do |opts|
    opts.banner = "Usage: chef-marketplace-ctl trim-actions-db [options]"

    opts.on("-s SIZE", "--size SIZE", String, "The desired Analytics Actions database size") do |db_size|
      @options[:db_size] = db_size
    end

    opts.on("-l LOGFILE", "--log LOGFILE", String, "The location of the Action trimmer logfile") do |log_file|
      @options[:log_file] = log_file
    end

    opts.on("-i INTERVAL", "--interval INTERVAL", String, "How often the trimmer is run in hours") do |interval|
      @options[:interval] = interval
    end

    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!(ARGV)

  ActionsTrimmer.new(@options).run
end
