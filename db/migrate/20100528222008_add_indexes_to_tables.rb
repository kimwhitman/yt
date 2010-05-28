class AddIndexesToTables < ActiveRecord::Migration
  def self.up
    add_index :comments, :video_id
    add_index :comments, :user_id
    add_index :comments, :is_public

    add_index :featured_videos, :video_id
    add_index :featured_videos, :starts_free_at
    add_index :featured_videos, :ends_free_at

    add_index :instructors_videos, :video_id
    add_index :instructors_videos, :instructor_id

    add_index :reviews, :video_id
    add_index :reviews, :user_id
    add_index :reviews, :is_public

    add_index :users, :email
    add_index :users, :created_at
    add_index :users, :account_id
    add_index :users, :ambassador_id
    add_index :users, :ambassador_name

    add_index :subscriptions, :next_renewal_at
    add_index :subscriptions, :subscription_plan_id
    add_index :subscriptions, :account_id

    add_index :subscription_payments, :account_id
    add_index :subscription_payments, :subscription_id

    add_index :related_videos, :video_id
    add_index :related_videos, :related_video_id

    add_index :videos, :is_public
    add_index :videos, :skill_level_id
  end

  def self.down
  end
end
