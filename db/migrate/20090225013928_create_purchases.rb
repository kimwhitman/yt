class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.string :first_name, :length => 255, :null => false
      t.string :last_name, :length => 255, :null => false
      t.string :card_number, :length => 255, :null => false
      t.string :card_type, :null => false
      
      t.string :invoice_no, :length => 255, :null => false
      t.string :transaction_code, :length => 255, :null => false
      t.string :status, :length => 255, :null => false
      
      t.belongs_to :user # not necessary if user hasn't logged in.
      t.timestamps
    end
  end

  def self.down
    drop_table :purchases
  end
end
