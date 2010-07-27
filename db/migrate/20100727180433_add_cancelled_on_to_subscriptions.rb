class AddCancelledOnToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :cancelled_at, :datetime
  end

  def self.down
    remove_column :subscriptions, :cancelled_at
  end
end
