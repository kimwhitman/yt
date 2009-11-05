class AddOffensiveFlagToComments < ActiveRecord::Migration
  def self.up
  	add_column :comments, :offensive, :boolean, :default => false
  end

  def self.down
  	remove_column :comments, :offensive
  end
end
