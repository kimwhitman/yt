class CreatePurchaseItems < ActiveRecord::Migration
  def self.up
    create_table :purchase_items do |t|      
      t.string :type, :null => false
      t.integer :price_in_cents, :null => false
      # Alright, this is in case the associated object "disappears"
      # and you need a friendly name to identify it.
      t.string :name, :length => 255, :null => false
      # Associations
      t.belongs_to :purchase, :null => false
      t.belongs_to :purchased_item, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_items
  end
end
