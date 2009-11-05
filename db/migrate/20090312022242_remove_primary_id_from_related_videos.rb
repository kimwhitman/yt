class RemovePrimaryIdFromRelatedVideos < ActiveRecord::Migration
  def self.up
    change_table :related_videos do |t|
      t.remove :id
    end
  end

  def self.down
    raise IrreversibleMigration.new
  end
end
