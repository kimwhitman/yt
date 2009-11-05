class AddFreeDateRangeToFeaturedVideos < ActiveRecord::Migration
  def self.up
    change_table :featured_videos do |t|
      t.datetime :starts_free_at
      t.datetime :ends_free_at
    end
  end

  def self.down
    change_table :featured_videos do |t|
      t.remove :starts_free_at
      t.remove :ends_free_at
    end
  end
end
