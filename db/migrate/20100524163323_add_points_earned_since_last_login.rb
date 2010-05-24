class AddPointsEarnedSinceLastLogin < ActiveRecord::Migration
  def self.up
    add_column :users, :points_earned_since_last_login, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :points_earned_since_last_login
  end
end
