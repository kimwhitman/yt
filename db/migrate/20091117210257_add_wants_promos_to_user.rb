class AddWantsPromosToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :wants_promos, :boolean, :default => false
  end

  def self.down
    remove_column :users, :wants_promos
  end
end
