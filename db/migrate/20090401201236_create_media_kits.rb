class CreateMediaKits < ActiveRecord::Migration
  def self.up
    create_table :media_kits do |t|
      t.string :name
      t.string :dimensions
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.integer :rank
      t.timestamps
    end
  end

  def self.down
    drop_table :media_kits
  end
end
