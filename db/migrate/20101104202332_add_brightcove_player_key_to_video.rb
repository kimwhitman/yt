class AddBrightcovePlayerKeyToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :brightcove_player_key, :string
  end

  def self.down
    remove_column :videos, :brightcove_player_key
  end
end
