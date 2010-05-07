class RemovePathFromShareUrls < ActiveRecord::Migration
  def self.up
    remove_column :share_urls, :path
  end

  def self.down
    add_column :share_urls, :path, :string
  end
end
