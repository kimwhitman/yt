class AddIsCancelledToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :is_cancelled, :boolean, :null => false, :default => false
    add_index :subscriptions, :is_cancelled
  end

  def self.down
    remove_column :subscriptions, :is_cancelled
  end
end
