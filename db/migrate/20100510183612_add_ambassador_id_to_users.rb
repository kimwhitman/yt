class AddAmbassadorIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ambassador_id, :integer
    add_index :users, :ambassador_id
  end

  def self.down
    add_index :users, :ambassador_id
    remove_column :users, :ambassador_id
  end
end
