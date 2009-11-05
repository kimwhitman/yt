class CreateRelatedVideos < ActiveRecord::Migration
  def self.up
    create_table :related_videos do |t|
      t.belongs_to :related_video
      t.belongs_to :video
      t.timestamps
    end
  end

  def self.down
    drop_table :related_videos
  end
end
