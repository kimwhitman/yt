class CreateVideosYogaTypes < ActiveRecord::Migration
  def self.up
    create_table :videos_yoga_types do |t|
      t.belongs_to :video
      t.belongs_to :yoga_type
      t.timestamps
    end
  end

  def self.down
    drop_table :videos_yoga_types
  end
end
