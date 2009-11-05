class AddDescriptionToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.text :description
    end
  end

  def self.down
  end
end
