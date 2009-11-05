class AddVideoFocusCache < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.string :video_focus_cache, :length => 255
    end
  end

  def self.down
    change_table :videos do |t|
      t.remove :video_focus_cache
    end
  end
end
