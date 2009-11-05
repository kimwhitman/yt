class AddPersonalMessageToUserStories < ActiveRecord::Migration
  def self.up
    change_table :user_stories do |t|
      t.text :personal_message
    end
  end

  def self.down
    change_table :user_stories do |t|
      t.remove :personal_message
    end
  end
end
