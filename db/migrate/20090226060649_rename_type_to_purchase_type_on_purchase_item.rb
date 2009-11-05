class RenameTypeToPurchaseTypeOnPurchaseItem < ActiveRecord::Migration
  def self.up
    change_table :purchase_items do |t|
      t.rename :type, :purchase_type
    end
  end

  def self.down
    t.rename :purchase_type, :type
  end
end
