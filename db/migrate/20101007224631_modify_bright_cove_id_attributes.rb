class ModifyBrightCoveIdAttributes < ActiveRecord::Migration
  def self.up
    remove_column :videos, :brightcove_id
    add_column :videos, :brightcove_full_video_id, :bigint
    add_column :videos, :brightcove_preview_video_id, :bigint
  end

  def self.down
    add_column :videos, :brightcove_id, :bigint
    remove_column :videos, :brightcove_full_video_id
    remove_column :videos, :brightcove_preview_video_id
  end
end