require 'erb'
require 'config/accelerator/accelerator_tasks'

set :application, "yogatoday_staging"
set :domain, 'staging.yogatoday.com'

set :deploy_to, "/var/www/apps/#{application}"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, domain
set :server_alias, domain
