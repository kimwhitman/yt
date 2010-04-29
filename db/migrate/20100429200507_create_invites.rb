class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer :user_id
      t.string :type, :recipients, :subject, :from, :state
      t.text :body
      t.boolean :is_default_body_for_user, :null => false, :default => false
      t.timestamps
    end

    add_index :invites, :user_id
    add_index :invites, :type
    add_index :invites, :state
    add_index :invites, :is_default_body_for_user
  end

  def self.down
    remove_index :invites, :user_id
    remove_index :invites, :type
    remove_index :invites, :state
    remove_index :invites, :is_default_body_for_user

    drop_table :invites
  end
end
