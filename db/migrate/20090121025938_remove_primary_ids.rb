class RemovePrimaryIds < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_table :instructors_videos do |t|
        t.remove 'id'
      end
      change_table :videos_yoga_types do |t|
        t.remove 'id'
      end
      change_table :videos_yoga_poses do |t|
        t.remove 'id'
      end
    end
  end

  def self.down
    raise IrreversibleMigration.new
  end
end
