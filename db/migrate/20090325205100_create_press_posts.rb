class CreatePressPosts < ActiveRecord::Migration
  def self.up
    create_table :press_posts do |t|
      t.string :title, :length => 255, :null => false
      t.text :body, :null => false
      # paperclip specific columns
      t.string :photo_file_name
      t.string :photo_content_type
      t.string :photo_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :press_posts
  end
end
