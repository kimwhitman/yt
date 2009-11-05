class CreateVideoFocus < ActiveRecord::Migration
  def self.up
    create_table :video_focus do |t|
      t.string :name, :null => false, :length => 255
      t.text :description
      t.belongs_to :video_focus_category
      t.timestamps
    end
  end

  def self.down
    drop_table :video_focus
  end
end
