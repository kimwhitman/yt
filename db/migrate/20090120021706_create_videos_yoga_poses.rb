class CreateVideosYogaPoses < ActiveRecord::Migration
  def self.up
    create_table :videos_yoga_poses do |t|
      t.belongs_to :video
      t.belongs_to :yoga_pose
      t.timestamps
    end
  end

  def self.down
    drop_table :videos_yoga_poses
  end
end
