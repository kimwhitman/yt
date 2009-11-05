class AddFieldsToPressPosts < ActiveRecord::Migration
  def self.up
    add_column :press_posts, :date_posted, :datetime
    add_column :press_posts, :intro, :text
    add_column :press_posts, :active, :boolean
    add_column :press_posts, :rank, :integer
  end

  def self.down
    remove_column :press_posts, :date_posted
    remove_column :press_posts, :intro
    remove_column :press_posts, :active
    remove_column :press_posts, :rank
  end
end
