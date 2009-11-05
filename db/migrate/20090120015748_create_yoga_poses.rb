class CreateYogaPoses < ActiveRecord::Migration
  def self.up
    create_table :yoga_poses do |t|
      t.string :name, :length => 255, :null => false
      t.text :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :yoga_poses
  end
end
