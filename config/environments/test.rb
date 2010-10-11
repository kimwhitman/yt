# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.gem 'rspec',       :lib => false, :version => '>=1.2.9' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'rspec-rails', :lib => false, :version => '>=1.2.9' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
config.gem 'timecop', :version => '0.3.4'
config.gem 'machinist', :lib => 'machinist', :version => '1.0.6'
config.gem 'fakeweb', :lib => false, :version => '1.2.8'

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
end

ActionController::Base.asset_host = "http://test"

DELVE_API_ACCESS_KEY = 'xUIk6ov+S6UoeaW6B9NExEx9hGE=';
DELVE_API_SECRET = 'yjqn3esX2QMzhbwFU03LXYwjj/s='

