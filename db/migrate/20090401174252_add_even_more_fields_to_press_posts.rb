class AddEvenMoreFieldsToPressPosts < ActiveRecord::Migration
  def self.up
    remove_column :press_posts, :caption
    remove_column :press_posts, :url
    remove_column :press_posts, :url_title
    add_column :press_posts, :caption, :string
    add_column :press_posts, :url, :string
    add_column :press_posts, :url_title, :string
  end

  def self.down
    add_column :press_posts, :caption, :datetime
    add_column :press_posts, :url, :text
    add_column :press_posts, :url_title, :boolean
    remove_column :press_posts, :caption
    remove_column :press_posts, :url
    remove_column :press_posts, :url_title
  end
end
