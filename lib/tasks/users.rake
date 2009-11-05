namespace :yogatoday do
  namespace :users do
    desc "Make sure all legacy users have an associated account."
    task :migrate_users_to_free_accounts => [:environment] do
      User.all(:conditions => { :account_id => nil }).each do |user|
        # safe call -- won't overwrite existing account settings.
        user.send :setup_free_account
      end
    end
  end
end
