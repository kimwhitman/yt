# Settings specified here will take precedence over those in config/environment.rb

HOST = 'yogatoday.com'

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
config.action_mailer.default_url_options = { :host => HOST, :only_path => false }

ActionController::Base.asset_host = Proc.new { |source, request|
  if request && request.ssl?
    "#{request.protocol}#{request.host_with_port}"
  else
    "http://assets#{ rand(4) + 1 }.#{ HOST }"
  end
}

Paperclip.options[:command_path] = '/opt/local/bin/'
