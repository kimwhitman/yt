class AdditionalSubscriptionColumns < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.integer :saved_subscription_plan_id, :null => true
    end
  end

  def self.down
    change_table :subscriptions do |t|
      t.remove :saved_subscription_plan_id
    end
  end
end
