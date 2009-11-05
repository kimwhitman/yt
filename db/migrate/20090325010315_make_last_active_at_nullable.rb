class MakeLastActiveAtNullable < ActiveRecord::Migration
  def self.up
    change_table :carts do |t|
      t.change :last_active_at, :datetime
    end
  end

  def self.down
    change_table :carts do |t|
      t.change :last_active_at, :datetime, :null => false
    end
  end
end
