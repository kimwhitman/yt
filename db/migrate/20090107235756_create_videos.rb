class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :title, :length => 255, :null => false
      t.integer :duration, :null => false
      t.string :preview_media_id, :length => 32
      t.string :streaming_media_id, :length => 32
      t.string :downloadable_media_id, :length => 32
      t.boolean :is_public, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
