# YogaToday

## Installation

For development, you'll need to install the gems for each environment:

    rake gems:install && rake gems:install RAILS_ENV=test && rake gems:install RAILS_ENV=cucumber



Then create a database.yml for development and test environments. Once you have them, run these rake tasks:

    rake db:create
    rake db:schema:load
    rake db:bootstrap

That should give you a sample set of data to get up and running

## Deploying apps

To deploy to the staging server:

    cap staging deloy

To deploy to the production server:

    TODO: incomplete