class AddFieldsToMediaKits < ActiveRecord::Migration
  def self.up
  	add_column :media_kits, :media_kit_type, :string
  end

  def self.down
  	remove_column :media_kits, :media_kit_type
  end
end
