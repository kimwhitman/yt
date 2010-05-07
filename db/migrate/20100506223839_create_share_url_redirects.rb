class CreateShareUrlRedirects < ActiveRecord::Migration
  def self.up
    create_table :share_url_redirects do |t|
      t.references :share_url
      t.references :user
      t.string :remote_ip
      t.string :referrer
      t.string :domain

      t.timestamps
    end

    add_index :share_url_redirects, :share_url_id
    add_index :share_url_redirects, :user_id
  end

  def self.down
    drop_table :share_url_redirects
  end
end
