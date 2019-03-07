APP_CONFIG = YAML.load(File.read(File.join(Rails.root, "config", "application.yml")))

# other config options
# strip the http:// part from host -- works without it anyway
# and getting stripped colon when passed full: https://github.com/plataformatec/devise/issues/1430
# ActionMailer::Base.default_url_options[:host] = APP_CONFIG["host"].sub('http://','')
ActionMailer::Base.smtp_settings = APP_CONFIG["smtp_settings"].symbolize_keys
ActionMailer::Base.smtp_settings[:authentication] = :plain
ActionMailer::Base.default :from => APP_CONFIG["smtp_settings"]["sender"]
