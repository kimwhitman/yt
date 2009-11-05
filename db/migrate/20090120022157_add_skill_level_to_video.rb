class AddSkillLevelToVideo < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.references :skill_level
    end
  end

  def self.down
    change_table :videos do |t|
      t.remove_references :skill_level
    end
  end
end
