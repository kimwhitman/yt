class AddMailchimpIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mailchimp_id, :text
  end

  def self.down
    remove_column :users, :mailchimp_id
  end
end
