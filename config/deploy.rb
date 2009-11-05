# do 'cap staging deploy' to deploy staging
# or 'cap production deploy' to deploy to production

# To run migrations, do 'cap STAGE deploy:migrate'

# To take a page down for maintenance do 'cap STAGE cap deploy:web:disable'
# To put it back up, do 'cap STAGE deploy:web:enable'

set :stages, %w(production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

deploy.task :setup_database_config do
  run "mv #{File.join(release_path, "config/database-production.yml")} #{File.join(release_path, "config/database.yml")}"
end

after "deploy:finalize_update", "deploy:setup_database_config"