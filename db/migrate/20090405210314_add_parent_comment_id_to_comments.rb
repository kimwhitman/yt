class AddParentCommentIdToComments < ActiveRecord::Migration
  def self.up
  	add_column :comments, :parent_comment_id, :integer
  end

  def self.down
  	remove_column :comments, :parent_comment_id
  end
end
