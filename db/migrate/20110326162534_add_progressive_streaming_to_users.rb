class AddProgressiveStreamingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :progressive_streaming, :boolean, :default => false
  end

  def self.down
    remove_column :users, :progressive_streaming
  end
end
