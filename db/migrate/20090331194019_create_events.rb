class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.boolean :active
      t.string :title
      t.text :copy
      t.datetime :begin_date
      t.datetime :end_date
      t.integer :rank
      t.string :url
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
