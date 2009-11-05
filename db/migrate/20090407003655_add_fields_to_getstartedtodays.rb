class AddFieldsToGetstartedtodays < ActiveRecord::Migration
  def self.up
  	add_column :get_started_todays, :link, :string
  end

  def self.down
  	remove_column :get_started_todays, :link
  end
end
