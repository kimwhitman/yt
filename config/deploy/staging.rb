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

deploy.task :restart do
  # accelerator.smf_restart
  accelerator.restart_apache
end

deploy.task :start do
  # accelerator.smf_start
  accelerator.restart_apache
end

deploy.task :stop do
  # accelerator.smf_stop
  accelerator.restart_apache
end

namespace :deploy do
  %w(start restart).each { |name| task name, :roles => :app do mod_rails.restart end }
end

after :deploy, 'deploy:cleanup'
