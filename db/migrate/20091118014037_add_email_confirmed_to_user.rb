class AddEmailConfirmedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_confirmed, :boolean, :default => false

    say "Updating existing users so they don't have to confirm their email address"

    User.update_all("email_confirmed = 1")
  end

  def self.down
    remove_column :users, :email_confirmed
  end
end
