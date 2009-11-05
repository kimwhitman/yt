class PurchaseItemLastDownloadedAt < ActiveRecord::Migration
  def self.up
    change_table :purchase_items do |t|
      t.datetime :last_downloaded_at
    end
  end

  def self.down
    change_table :purchase_items do |t|
      t.remove :last_downloaded_at
    end
  end
end
