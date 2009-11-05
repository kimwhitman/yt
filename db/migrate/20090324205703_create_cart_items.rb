class CreateCartItems < ActiveRecord::Migration
  def self.up
    create_table :cart_items do |t|
      t.string :product_name, :length => 255, :null => false
      t.integer :amount, :null => false
      
      t.belongs_to :cart, :null => false
      t.references :product, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :cart_items
  end
end
