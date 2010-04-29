class AddAmbassadorColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invitations_count, :integer, :null => false, :default => 0
    add_column :users, :successful_referrals_count, :integer, :null => false, :default => 0
    add_column :users, :points_earned, :integer, :null => false, :default => 0
    add_column :users, :points_used, :integer, :null => false, :default => 0
    add_column :users, :points_current, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :invitations_count
    remove_column :users, :successful_referrals_count
    remove_column :users, :points_earned
    remove_column :users, :points_used
    remove_column :users, :points_current
  end
end
