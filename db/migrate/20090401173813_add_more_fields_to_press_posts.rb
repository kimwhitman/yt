class AddMoreFieldsToPressPosts < ActiveRecord::Migration
  def self.up
    add_column :press_posts, :caption, :datetime
    add_column :press_posts, :url, :text
    add_column :press_posts, :url_title, :boolean
  end

  def self.down
    remove_column :press_posts, :caption
    remove_column :press_posts, :url
    remove_column :press_posts, :url_title
  end
end
