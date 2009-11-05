class CreateVideoVideoFocus < ActiveRecord::Migration
  def self.up
    create_table :video_video_focus, :id => false do |t|
      t.belongs_to :video_focus
      t.belongs_to :video
      t.timestamps
    end
  end

  def self.down
    drop_table :video_video_focus
  end
end
