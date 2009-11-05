class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :billing_id, :null => false
      t.string :billing_type, :length => 255, :null => false
      t.string :authorization_code, :length => 255, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
