class CreateShareUrls < ActiveRecord::Migration
  def self.up
    create_table :share_urls do |t|
      t.references :shareable
      t.string :shareable_type
      t.string :token

      t.timestamps
    end
    
    add_index :share_urls, [:shareable_id, :shareable_type]
  end

  def self.down
    drop_table :share_urls
  end
end
