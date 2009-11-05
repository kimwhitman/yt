class AddCrapToUserStories < ActiveRecord::Migration
  def self.up
    change_table :user_stories do |t|
      t.boolean :is_public, :null => false, :default => false
      t.datetime :publish_at
    end
  end

  def self.down
    change_table :user_stories do |t|
      t.remove :is_public
      t.datetime :publish_at
    end
  end
end
