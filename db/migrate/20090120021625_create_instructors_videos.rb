class CreateInstructorsVideos < ActiveRecord::Migration
  def self.up
    create_table :instructors_videos do |t|
      t.belongs_to :video
      t.belongs_to :instructor
      t.timestamps
    end
  end

  def self.down
    drop_table :instructors_videos
  end
end
