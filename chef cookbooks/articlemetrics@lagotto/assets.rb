Rails.application.config.assets.precompile += %W( api_requests/*.js works/*.js relations/*.js deposits/*.js contributions/*.js sources/*.js agents/*.js contributors/*.js layouts/*.js publishers/*.js status/*.js api/*.js docs/*.js #{ENV['MODE']}.css )
