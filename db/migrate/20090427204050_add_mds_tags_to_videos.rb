class AddMdsTagsToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.string :mds_tags
    end
  end

  def self.down
    change_table :videos do |t|
      t.remove :mds_tags
    end
  end
end
