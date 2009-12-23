# Settings specified here will take precedence over those in config/environment.rb

HOST = 'yoga.local'

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# config.log_level = :info

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = { :host => HOST, :only_path => false }
config.action_mailer.delivery_method = :test

config.after_initialize do
  ActiveMerchant::Billing::Base.gateway_mode = :test
end

# Delve Platform Values
#ENV['organization_id'] = '59b93524ab7c4d62b53d7553360c2b87'
#ENV['api_domain'] = 'staging-api.delvenetworks.com/rest'
#DELVE_API_ACCESS_KEY = 'xUIk6ov+S6UoeaW6B9NExEx9hGE=';
#DELVE_API_SECRET = 'yjqn3esX2QMzhbwFU03LXYwjj/s='
