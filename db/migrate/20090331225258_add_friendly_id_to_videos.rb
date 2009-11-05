class AddFriendlyIdToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.string :friendly_name, :length => 255
    end
  end

  def self.down
    change_table :videos do |t|
      t.remove :friendly_name, :length => 255
    end
  end
end
