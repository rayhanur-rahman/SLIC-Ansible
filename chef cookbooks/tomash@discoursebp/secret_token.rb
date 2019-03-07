# We have had lots of config issues with SECRET_TOKEN to avoid this mess we are moving it to redis
#  if you feel strongly that it does not belong there use ENV['SECRET_TOKEN']
#
Discourse::Application.config.secret_token = APP_CONFIG['secret_token']
token = ENV['SECRET_TOKEN']
unless token
  token = $redis.get('SECRET_TOKEN')
  unless token && token.length == 128
    token = SecureRandom.hex(64)
    $redis.set('SECRET_TOKEN',token)
  end
end

Discourse::Application.config.secret_token = token

APP_CONFIG = YAML.load(File.read(File.join(Rails.root, "config", "application.yml")))