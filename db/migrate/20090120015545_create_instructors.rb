class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors do |t|
      t.string :name, :length => 255, :null => false
      t.text :biography
      t.string :photo_url, :length => 255
      t.timestamps
    end
  end

  def self.down
    drop_table :instructors
  end
end
