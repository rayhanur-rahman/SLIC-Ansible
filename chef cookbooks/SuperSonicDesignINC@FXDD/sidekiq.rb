require "#{Rails.root}/lib/discourse_redis"
require 'autoscaler/sidekiq'
require 'autoscaler/heroku_scaler'

$redis = DiscourseRedis.new

if Rails.env.development? && !ENV['DO_NOT_FLUSH_REDIS']
  puts "Flushing redis (development mode)"
  $redis.flushall
end

Sidekiq.configure_server do |config|
  config.redis = { :url => $redis.url, :namespace => 'sidekiq', :size => 3 }
  config.server_middleware do |chain|
    chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuScaler.new, 60)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => $redis.url, :namespace => 'sidekiq', :size => 3 }
  config.client_middleware do |chain|
    chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuScaler.new
  end
end