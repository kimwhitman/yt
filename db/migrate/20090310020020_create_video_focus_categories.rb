class CreateVideoFocusCategories < ActiveRecord::Migration
  def self.up
    create_table :video_focus_categories do |t|
      t.string :name, :null => false, :length => 255
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :video_focus_categories
  end
end
