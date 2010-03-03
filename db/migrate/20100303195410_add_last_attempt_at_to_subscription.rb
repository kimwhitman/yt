class AddLastAttemptAtToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :last_attempt_at, :datetime
    add_column :subscriptions, :last_attempt_successful, :boolean, :default => true
  end

  def self.down
    remove_column :subscriptions, :last_attempt_at
    remove_column :subscriptions, :last_attempt_successful
  end
end
