require 'erb'
require 'config/accelerator/accelerator_tasks'

set :application, "yogatoday"
set :domain, 'yogatoday.com'
set :scm, :git

set :repository,  "git@github.com:kimwhitman/YogaToday.git"

set :rake, "/opt/local/bin/rake"
set :deploy_to, "/var/www/apps/#{application}"
set :user, 'yoga'
set :password, "y0g4"
set :runner, 'yoga'
set :use_sudo, false

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, domain
set :server_alias, domain

deploy.task :restart do
  accelerator.smf_restart
  accelerator.restart_apache
end

deploy.task :start do
  accelerator.smf_start
  accelerator.restart_apache
end

deploy.task :stop do
  accelerator.smf_stop
  accelerator.restart_apache
end

after :deploy, 'deploy:cleanup'
