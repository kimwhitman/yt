class AddAmbassadorNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ambassador_name, :string
    add_index :users, :ambassador_name
  end

  def self.down
    remove_index :users, :ambassador_name
    remove_column :users, :ambassador_name
  end
end
