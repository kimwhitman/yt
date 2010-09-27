class AddBrightcoveIdToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :brightcove_id, :bigint

    add_index :videos, :brightcove_id
  end

  def self.down
    remove_column :videos, :brightcove_id
  end
end
