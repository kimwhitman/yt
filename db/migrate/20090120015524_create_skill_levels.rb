class CreateSkillLevels < ActiveRecord::Migration
  def self.up
    create_table :skill_levels do |t|
      t.string :name, :null => false
      t.string :description, :null => false, :length => 255
      
      t.timestamps
    end
  end

  def self.down
    drop_table :skill_levels
  end
end
