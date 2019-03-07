worker_processes 4
working_directory "/home/zdun/apps/sharelex-discourse/current"

listen "/tmp/sharelex-discourse.unicorn.sock.0", :backlog => 64
listen "/tmp/sharelex-discourse.unicorn.sock.1", :backlog => 64

timeout 30

pid "/home/zdun/apps/sharelex-discourse/tmp/unicorn.pid"

stderr_path "/home/zdun/apps/sharelex-discourse/current/log/unicorn.stderr.log"
stdout_path "/home/zdun/apps/sharelex-discourse/current/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  $redis.client.reconnect
  MessageBus.reliable_pub_sub.pub_redis.client.reconnect
  Rails.cache.reconnect
end
