# Settings specified here will take precedence over those in config/environment.rb

HOST = 'staging.yogatoday.com'

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
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true

# Delve Platform Values
# ENV['organization_id'] = '59b93524ab7c4d62b53d7553360c2b87'
# ENV['api_domain'] = 'staging-api.delvenetworks.com/rest'
# DELVE_API_ACCESS_KEY = 'xUIk6ov+S6UoeaW6B9NExEx9hGE=';
# DELVE_API_SECRET = 'yjqn3esX2QMzhbwFU03LXYwjj/s='

config.action_controller.session = {
  :session_key => '_yogatoday_staging',
  :secret      => 'hoht9824htr924ht924hth429h429hf92n439rh29hr923r9823yt93qyt98h32f924yr923h93h23d9h230h239fh23fh24th240th240th'
}

config.log_level = :info

config.after_initialize do
  ActiveMerchant::Billing::Base.gateway_mode = :test
end

ActionController::Base.asset_host = Proc.new { |source, request|
  if request && request.ssl?
    "#{request.protocol}#{request.host_with_port}"
  else
    "http://assets#{rand(4) + 1}.yogatoday.com"
  end
}

Paperclip.options[:command_path] = '/opt/local/bin/'

Savon::Request.logger = Logger.new("#{RAILS_ROOT}/log/soap_staging.txt")
Savon::Request.log_level = :debug
Savon::Response.raise_errors = false
