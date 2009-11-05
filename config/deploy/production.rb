require 'erb'
require 'config/accelerator/accelerator_tasks'
 
set :application, "yogatoday" #matches names used in smf_template.erb
set :repository,  "https://dev.pluggd.com/svn/projects/yogatoday/trunk/"
 
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}" # I like this location
 
set :user, 'yoga'
set :password, "y0g4"
set :runner, 'yoga'
 
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion

# keep a cached code checkout on the server, and do updates each time (more efficient)
#set :deploy_via, :remote_cache
set :deploy_via, :export

# Set the path to svn and rake if needed(Does not seem to be necessary on the newpkgsrc templated accelerators, but if needed change path to /opt/local/bin/ )
set :svn, "/opt/csw/bin/svn"
set :rake, "/opt/local/bin/rake"
#set :rake, "/opt/jruby/bin/jruby -S rake"

# Use if capistrano can't find your local svn
set :local_scm_command, "/usr/bin/svn"
 
 
set :domain, '72.2.117.138'
 
role :app, domain
role :web, domain
role :db,  domain, :primary => true
 
set :server_name, "gnsj4faa.joyent.us"
set :server_alias, "gnsj4faa.joyent.us"
 
# Example dependancies
# Try these with jruby....
#depend :remote, :command, :gem
#depend :remote, :gem, :money, '>=1.7.1'
#depend :remote, :gem, :mongrel, '>=1.0.1'
#depend :remote, :gem, :image_science, '>=1.1.3'
#depend :remote, :gem, :rake, '>=0.7'
#depend :remote, :gem, :BlueCloth, '>=1.0.0'
#depend :remote, :gem, :RubyInline, '>=3.6.3'
 
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
