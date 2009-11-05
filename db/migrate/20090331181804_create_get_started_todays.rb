class CreateGetStartedTodays < ActiveRecord::Migration
  def self.up
    create_table :get_started_todays do |t|
      t.string :heading
      t.text :content
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :get_started_todays
  end
end
