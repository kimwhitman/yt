class AlterShareUrlSchema < ActiveRecord::Migration
  def self.up
    remove_column :share_urls, :shareable_id
    remove_column :share_urls, :shareable_type
    
    add_column :share_urls, :user_id, :integer
    add_column :share_urls, :path, :string
    add_column :share_urls, :destination, :string
    
    add_index :share_urls, :user_id
    add_index :share_urls, :token
    add_index :share_urls, :path
  end

  def self.down
    add_column :share_urls, :shareable_id, :integer
    add_column :share_urls, :shareable_type, :string
    
    remove_column :share_urls, :user_id
    remove_column :share_urls, :path
    
    remove_index :share_urls, :user_id
    remove_index :share_urls, :token
    remove_index :share_urls, :path
  end
end
