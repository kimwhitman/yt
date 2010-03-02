class AddPublishedAtToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :published_at, :datetime
    
    add_index :videos, :published_at
    
    Video.all.each do |video|
      video.update_attributes(:published_at => video.created_at)
    end
  end

  def self.down
    remove_column :videos, :published_at
  end
end
