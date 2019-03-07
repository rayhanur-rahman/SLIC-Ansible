#!/usr/bin/env ruby

require 'socket'

# - Run the given project, e.g., opscode-account, with the branches specified
#   and their corresponding services running with the right branch's code. See
#   usage message text below.
DEFAULT_REMOTE = "opscode"   # if no remote specified, use this.
BASE_REMOTE = nil            # after we're done, go back to this remote ...
BASE_BRANCH = "deploy"       #   and branch
SERVICES_TO_RESTART = {
  "opscode-chef" => ["opscode-chef", "opscode-webui"],
  "opscode-account" => ["opscode-account"],
  "opscode-authz" => ["opscode-authz"],
  
  "chef" => ["chef-server"]
}

def usage
  puts <<-EOM
#{$0} [--branch PROJ1_NAME=[PROJ1_REMOTE/]PROJ1_BRANCH ...] RUN_PROJ_NAME (rake|cucumber) [RAKE_OR_CUCUMBER_OPTIONS]

  Runs cucumber or rake with the given CUCUMBER_OPTIONS for the given 
  RUN_PROJ_NAME, by executing 
  /srv/hudson/continuous-integration/hudson/run-cucumber.sh or run-rake.sh.
  If specified in --branch options, switches branches of those projects before
  running the tests and restarts affected services (see SERVICES_TO_RESTART in
  #{$0}). Will switch back to base branch (#{BASE_BRANCH}) after running 
  the tests then restart the affected services again.

EXAMPLES:
  #{$0} --branch opscode-account=billing --branch opscode-chef=billing opscode-chef cucumber -t @webui
  #{$0} --branch chef=pl-master chef rake spec
  #{$0} --branch chef=master chef rake spec
  
  EOM
end

def do_system(cmd)
  puts "--- #{cmd}"
  system cmd
end

# Switches to remote_wanted/branch_wanted.
def switch_branch(project_name, remote_wanted, branch_wanted)
  branch_str = remote_wanted ? "#{remote_wanted}/#{branch_wanted}" : branch_wanted
  
  puts "+++ Switching branch for #{project_name} to #{branch_str}"
  Dir.chdir("/srv/#{project_name}/current") do |dir|
    if remote_wanted
      if !(do_system "git fetch #{remote_wanted}")
        raise "Couldn't fetch from remote #{remote_wanted}"
      end
    end
    
    if !(do_system "git checkout -f #{branch_str}")
      raise "Couldn't switch to branch #{branch_str}"
    end
    
    if File.exist?("Gemfile.lock")
      do_system "bundle install --deployment"
    end

    services_to_restart = SERVICES_TO_RESTART[project_name] || []
    services_to_restart.each do |service|
      do_system "/etc/init.d/#{service} force-restart"
    end
  end
  puts
end

def parse_command_line
  $tobranch_project_branch = Hash.new
  $tobranch_project_remote = Hash.new

  # Keep pulling off --branch lines until we exhaust them.
  begin
    branch_arg_index = ARGV.find_index("--branch")
    if branch_arg_index
      ARGV.delete_at(branch_arg_index)
      branch_arg_str = ARGV.delete_at(branch_arg_index)

      # opscode-account=opscode/master
      # opscode-chef=master
      # chef=pl-master
      if branch_arg_str =~ /^(.+)=(.+)$/
        proj_name = $1
        branch = $2
        if branch =~ /^(.+)\/(.+)$/
          remote = $1
          branch = $2
        else
          remote = DEFAULT_REMOTE
        end

        unless SERVICES_TO_RESTART[proj_name]
          raise "Don't know what to restart for #{proj_name}: update SERVICES_TO_RESTART in #{$0}"
        end

        $tobranch_project_remote[proj_name] = remote
        $tobranch_project_branch[proj_name] = branch
      else
        raise "Don't know how to parse #{branch_arg_str}: should be form PROJNAME=[REMOTE/]BRANCH"
      end
    end
  end while branch_arg_index


  # project name first.
  $project_name = ARGV.shift

  # then 'rake' or 'cucumber'
  $rake_or_cucumber = case ARGV.shift
  when "rake"
    "run-rake.sh"
  when "cucumber"
    "run-cucumber.sh"
  else
    nil
  end

  # Check arguments.
  unless ($rake_or_cucumber && $project_name)
    usage
    exit
  end

end

parse_command_line

puts "*** project_name #{$project_name}, rake_or_cucumber #{$rake_or_cucumber}"
puts "*** tobranch_project_remote = #{$tobranch_project_remote.inspect}; tobranch_project_branch = #{$tobranch_project_branch.inspect}"
puts

begin
  # Actually switch the branches.
  puts "+++ Switching branches ..."
  $tobranch_project_branch.keys.each do |tobranch_proj_name|
    switch_branch(tobranch_proj_name, $tobranch_project_remote[tobranch_proj_name], $tobranch_project_branch[tobranch_proj_name])
  end

  # Run run-rake/run-cucumber.
  cmdline = ["/srv/opscode-test/current/continuous-integration/hudson/#{$rake_or_cucumber}", $project_name, *ARGV]
  cmdline_str = cmdline.map {|arg| (arg =~ /\s+/) ? "\"#{arg}\"" : arg}.join(" ")
  puts "*** Running test #{cmdline_str}"
  
  system *cmdline
  
  ret_code = $?.exitstatus
ensure
  # Switch the branches back.
  puts
  puts "+++ Switching branches back..."
  $tobranch_project_branch.keys.each do |tobranch_proj_name|
    switch_branch(tobranch_proj_name, BASE_REMOTE, BASE_BRANCH)
  end
  
end

# return with the same error code that run-rake/run-cucumber returned.
puts "*** #{$rake_or_cucumber} returned exit code #{ret_code}."
exit ret_code

