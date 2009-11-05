class AddFreeColumnToFeaturedVideos < ActiveRecord::Migration
  def self.up
    change_table :featured_videos do |t|
      t.boolean :free, :default => false
    end
  end

  def self.down
    change_table :featured_videos do |t|
      t.remove :free
    end
  end
end
