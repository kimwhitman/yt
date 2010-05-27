class AddHasUsedAmbassadorPlansToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :has_used_ambassador_plans, :boolean, :null => false, :default => false
    add_index :users, :has_used_ambassador_plans
  end

  def self.down
    remove_index :users, :has_used_ambassador_plans
    remove_column :users, :has_used_ambassador_plans
  end
end
