add_command_under_category "test", "Test", "Verify that the Chef Server Marketplace add-on is working properly", 2 do
  puts "Running chef-marketplace unit tests.."

  exit(
    run_command(
      "cd /opt/chef-marketplace &&" \
      "/opt/chef-marketplace/embedded/bin/rake spec --trace"
    ).exitstatus
  )
end
