class AddTitleToUserStory < ActiveRecord::Migration
  def self.up
    change_table :user_stories do |t|
      t.string :title, :length => 255
    end
  end

  def self.down
    change_table :user_stories do |t|
      t.remove :title
    end
  end
end
