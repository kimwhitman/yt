# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  config.gem 'lockfile', :version => '1.4.3'
  config.gem 'rest-client', :lib => 'rest_client', :version => '0.8.2'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :version => '~> 2.2.3', :source => 'http://gems.github.com'
  config.gem 'calendar_date_select', :version => '1.15'
  config.gem 'fastercsv', :version => '1.4'
  config.gem 'paperclip'

  #config.gem 'rmagick', :lib => 'RMagick' (EAE - skip for jruby)
  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_yogatoday_session_4',
    :secret      => '66e58aaaef55b97fabe8749c8111629513765d42ee55e0a73434bfdff6cd72c109fca50ba862012d6fcfdf6e95969787496a391f03f9ee1b08630b884c091e83'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.cache_store = :file_store, 'tmp/cache'
end

require 'association_proxy'
require "#{RAILS_ROOT}/config/initializers/net_http_patch.rb" # Rails Lazy Loading in production
ExceptionNotifier.exception_recipients = %w(log-watchers@delvenetworks.com)

ExceptionNotifier.sender_address = %("YogaToday Application Error" <app.error@yogatoday.com>)

# defaults to "[ERROR] "

ExceptionNotifier.email_prefix = "[YOGATODAY-ERROR] "

