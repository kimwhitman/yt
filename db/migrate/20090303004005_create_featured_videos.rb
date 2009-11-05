class CreateFeaturedVideos < ActiveRecord::Migration
  def self.up
    create_table :featured_videos do |t|
      t.integer :rank, :null => false
      
      # File stuff.
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_file_size
      t.string :image_updated_at
      
      # Associations
      t.belongs_to :video, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :featured_videos
  end
end
