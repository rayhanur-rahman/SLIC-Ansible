
# Definitely change this when you deploy to production. Ours is replaced by jenkins.
# This token is used to secure sessions, we don't mind shipping with one to ease test and debug,
#  however, the stock one should never be used in production, people will be able to crack
#  session cookies.
#
# Generate a new secret with "rake secret".  Copy the output of that command and paste it
# in your secret_token.rb as the value of Discourse::Application.config.secret_token:
#
# Discourse::Application.config.secret_token = "SET_SECRET_HERE"

# if Rails.env.test? || Rails.env.development? || Rails.env == "profile"
#   Discourse::Application.config.secret_token = "47f5390004bf6d25bb97083fb98e7cc133ab450ba814dd19638a78282b4ca291"
# else
#   raise "You must set a secret token in ENV['SECRET_TOKEN'] or in config/initializers/secret_token.rb" if ENV['SECRET_TOKEN'].blank?
  Discourse::Application.config.secret_token = "95170118664aaff157d7e625a88129bf29544ba0ffdab8b03e69e58fa2fff50006a6adaac914186d5d494530ee4fe016eedb3d261d9a8b8e973c1e4b82263926"
# end

