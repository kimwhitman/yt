class CreatePlaylistVideos < ActiveRecord::Migration
  def self.up
    create_table :playlist_videos do |t|
      t.belongs_to :video, :null => false
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_videos
  end
end
