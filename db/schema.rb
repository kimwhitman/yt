# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091118160607) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_domain"
    t.datetime "deleted_at"
    t.integer  "subscription_discount_id", :limit => 11
  end

  create_table "billing_transactions", :force => true do |t|
    t.integer  "billing_id",         :limit => 11, :null => false
    t.string   "billing_type",                     :null => false
    t.string   "authorization_code",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",             :limit => 11, :null => false
  end

  create_table "cart_items", :force => true do |t|
    t.string   "product_name",               :null => false
    t.integer  "amount",       :limit => 11, :null => false
    t.integer  "cart_id",      :limit => 11, :null => false
    t.integer  "product_id",   :limit => 11
    t.string   "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id",        :limit => 11
    t.datetime "last_active_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "video_id",          :limit => 10,                    :null => false
    t.integer  "user_id",           :limit => 10,                    :null => false
    t.boolean  "is_public",                                          :null => false
    t.string   "title"
    t.text     "content",                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_comment_id", :limit => 11
    t.boolean  "offensive",                       :default => false
  end

  create_table "events", :force => true do |t|
    t.boolean  "active"
    t.string   "title"
    t.text     "copy"
    t.datetime "begin_date"
    t.datetime "end_date"
    t.integer  "rank",               :limit => 11
    t.string   "url"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faqs", :force => true do |t|
    t.text     "question",                      :null => false
    t.text     "answer",                        :null => false
    t.integer  "faq_category_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "featured_videos", :force => true do |t|
    t.integer  "rank",               :limit => 11, :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.string   "image_updated_at"
    t.integer  "video_id",           :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_free_at"
    t.datetime "ends_free_at"
  end

  create_table "get_started_todays", :force => true do |t|
    t.string   "heading"
    t.text     "content"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank",               :limit => 11
    t.string   "link"
  end

  create_table "instructors", :force => true do |t|
    t.string   "name",                             :null => false
    t.text     "biography"
    t.string   "photo_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size",    :limit => 11
  end

  create_table "instructors_videos", :id => false, :force => true do |t|
    t.integer  "video_id",      :limit => 10
    t.integer  "instructor_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_kits", :force => true do |t|
    t.string   "name"
    t.string   "dimensions"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :limit => 11
    t.integer  "rank",               :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_kit_type"
  end

  create_table "password_resets", :force => true do |t|
    t.string   "email"
    t.integer  "user_id",    :limit => 11
    t.string   "remote_ip"
    t.string   "token"
    t.datetime "created_at"
  end

  create_table "playlist_videos", :force => true do |t|
    t.integer  "video_id",   :limit => 10, :null => false
    t.integer  "user_id",    :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_posts", :force => true do |t|
    t.string   "title",                            :null => false
    t.text     "body",                             :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_posted"
    t.text     "intro"
    t.boolean  "active"
    t.integer  "rank",               :limit => 11
    t.string   "caption"
    t.string   "url"
    t.string   "url_title"
  end

  create_table "purchase_items", :force => true do |t|
    t.string   "purchase_type"
    t.integer  "price_in_cents",     :limit => 10, :null => false
    t.string   "name",                             :null => false
    t.integer  "purchase_id",        :limit => 10, :null => false
    t.integer  "purchased_item_id",  :limit => 10, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_downloaded_at"
  end

  create_table "purchases", :force => true do |t|
    t.string   "first_name",                     :null => false
    t.string   "last_name",                      :null => false
    t.string   "card_number",                    :null => false
    t.string   "card_type",                      :null => false
    t.string   "invoice_no",                     :null => false
    t.string   "transaction_code",               :null => false
    t.string   "status",                         :null => false
    t.integer  "user_id",          :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                          :null => false
  end

  create_table "related_videos", :id => false, :force => true do |t|
    t.integer  "related_video_id", :limit => 11
    t.integer  "video_id",         :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "video_id",   :limit => 10, :null => false
    t.integer  "user_id",    :limit => 10, :null => false
    t.boolean  "is_public",                :null => false
    t.string   "title"
    t.text     "content",                  :null => false
    t.integer  "score",      :limit => 10, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skill_levels", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",     :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "account_id",      :limit => 11
    t.integer  "subscription_id", :limit => 11
    t.decimal  "amount",                        :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",                       :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_limit",     :limit => 11
    t.integer  "renewal_period", :limit => 11,                                :default => 1
    t.decimal  "setup_amount",                 :precision => 10, :scale => 2
    t.integer  "trial_period",   :limit => 11,                                :default => 1
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                                   :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                                   :default => "trial"
    t.integer  "subscription_plan_id",       :limit => 11
    t.integer  "account_id",                 :limit => 11
    t.integer  "user_limit",                 :limit => 11
    t.integer  "renewal_period",             :limit => 11,                                :default => 1
    t.string   "billing_id"
    t.integer  "saved_subscription_plan_id", :limit => 11
    t.datetime "saved_next_renewal_at"
  end

  create_table "user_stories", :force => true do |t|
    t.string   "name",                                                   :null => false
    t.string   "location",                                               :null => false
    t.string   "email",                                                  :null => false
    t.text     "story",                                                  :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",       :limit => 10
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.boolean  "is_public",                           :default => false, :null => false
    t.datetime "publish_at"
    t.boolean  "has_announced_publish",               :default => false, :null => false
    t.text     "personal_message"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "name"
    t.string   "remember_token"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "account_id",                :limit => 11
    t.boolean  "admin",                                   :default => false
    t.boolean  "wants_newsletter",                        :default => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size",           :limit => 11
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "newsletter_format",                       :default => "html"
    t.boolean  "wants_promos",                            :default => false
    t.boolean  "email_confirmed",                         :default => false
    t.string   "confirmation_token"
  end

  create_table "video_focus", :force => true do |t|
    t.string   "name",                                  :null => false
    t.text     "description"
    t.integer  "video_focus_category_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank",                    :limit => 11
  end

  create_table "video_focus_categories", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "video_video_focus", :id => false, :force => true do |t|
    t.integer  "video_focus_id", :limit => 11
    t.integer  "video_id",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "title",                               :null => false
    t.integer  "duration",              :limit => 10, :null => false
    t.string   "preview_media_id"
    t.string   "streaming_media_id"
    t.string   "downloadable_media_id"
    t.boolean  "is_public",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "skill_level_id",        :limit => 10
    t.string   "friendly_name"
    t.string   "mds_tags"
    t.string   "video_focus_cache"
  end

  create_table "videos_yoga_poses", :id => false, :force => true do |t|
    t.integer  "video_id",     :limit => 10
    t.integer  "yoga_pose_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos_yoga_types", :id => false, :force => true do |t|
    t.integer  "video_id",     :limit => 10
    t.integer  "yoga_type_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "yoga_poses", :force => true do |t|
    t.string   "name",                      :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank",        :limit => 11
  end

  create_table "yoga_types", :force => true do |t|
    t.string   "name",                      :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank",        :limit => 11
  end

end
