class AddEmailToPurchase < ActiveRecord::Migration
  def self.up
    change_table :purchases do |t|
      t.string :email, :length => 255, :null => false
    end
  end

  def self.down
    t.remove :email
  end
end
