class AddAnnouncePublishToUserStories < ActiveRecord::Migration
  def self.up
    change_table :user_stories do |t|
      t.boolean :has_announced_publish, :null => false, :default => false
    end
  end

  def self.down
    change_table :user_stories do |t|
      t.remove :has_announced_publish
    end
  end
end
