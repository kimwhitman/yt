require 'erb'
require 'config/accelerator/accelerator_tasks'

set :application, "yogatoday_staging"
set :rails_env, "staging"
set :domain, 'staging.yogatoday.com'
set :branch, "staging" # or whatever branch/tag/SHA1
set :deploy_to, "/var/www/apps/#{application}"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, domain
set :server_alias, domain
