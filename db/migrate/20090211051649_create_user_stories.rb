class CreateUserStories < ActiveRecord::Migration
  def self.up
    create_table :user_stories do |t|
      t.string :name, :length => 255, :null => false
      t.string :location, :length => 255, :null => false
      t.string :email, :length => 255, :null => false
      t.text :story, :null => false
      # Paperclip columns
      t.string :image_file_name, :length => 255
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :user_stories
  end
end
