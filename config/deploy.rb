# do 'cap staging deploy' to deploy staging
# or 'cap production deploy' to deploy to production

# To run migrations, do 'cap STAGE deploy:migrate'

# To take a page down for maintenance do 'cap STAGE cap deploy:web:disable'
# To put it back up, do 'cap STAGE deploy:web:enable'

set :stages, %w(production staging)
set :default_stage, "staging"

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

after 'deploy:setup', 'accelerator:restart_apache'
after 'deploy:update_code', 'config:symlinks'
