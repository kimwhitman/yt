class AddBrightcovePlayerIdToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :brightcove_player_id, :bigint
  end

  def self.down
    remove_column :videos, :brightcove_player_id
  end
end
