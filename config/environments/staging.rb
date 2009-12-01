# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = { :host => "staging.yogatoday.com", :only_path => false }

# Delve Platform Values
# ENV['organization_id'] = '59b93524ab7c4d62b53d7553360c2b87'
# ENV['api_domain'] = 'staging-api.delvenetworks.com/rest'
# DELVE_API_ACCESS_KEY = 'xUIk6ov+S6UoeaW6B9NExEx9hGE=';
# DELVE_API_SECRET = 'yjqn3esX2QMzhbwFU03LXYwjj/s='

config.after_initialize do
  #ActiveMerchant::Billing::Base.gateway_mode = :test
end

IMAGE_PATH = "http://staging.yogatoday.com/images"