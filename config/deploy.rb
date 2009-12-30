# do 'cap staging deploy' to deploy staging
# or 'cap production deploy' to deploy to production

# To run migrations, do 'cap STAGE deploy:migrate'

# To take a page down for maintenance do 'cap STAGE cap deploy:web:disable'
# To put it back up, do 'cap STAGE deploy:web:enable'

set :stages, %w(production staging)
set :default_stage, "staging"

set :rake, "/opt/local/bin/rake"
set :repository, "git@github.com:kimwhitman/YogaToday.git"
set :scm, :git
set :branch, "master" # or whatever branch/tag/SHA1

set :user, 'yoga'
set :password, "y0g4"
set :runner, 'yoga'
set :use_sudo, false

begin
  require 'capistrano/ext/multistage'
rescue LoadError => e
  puts "Please install multistage: gem install capistrano-ext"
  exit
end

namespace :config do
  desc "Make symlink for database yaml"
  task :symlinks do
    ['database.yml', 'mongrel_cluster.yml'].each do |name|
      run "ln -nfs #{shared_path}/#{name} #{release_path}/config/#{name}"
    end
  end
end

namespace :deploy do
  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

after 'deploy:update_code', 'config:symlinks'

