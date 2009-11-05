class AddSavedNextRenewalAt < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.datetime :saved_next_renewal_at, :null => true
    end
  end

  def self.down
    change_table :subscriptions do |t|
      t.remove :saved_next_renewal_at
    end
  end
end
