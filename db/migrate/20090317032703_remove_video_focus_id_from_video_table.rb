class RemoveVideoFocusIdFromVideoTable < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.remove_belongs_to :video_focus
    end
  end

  def self.down
    change_table :videos do |t|
      t.belongs_to :video_focus
    end
  end
end
