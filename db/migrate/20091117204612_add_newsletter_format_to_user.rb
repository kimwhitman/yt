class AddNewsletterFormatToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :newsletter_format, :string, :default => 'html'
  end

  def self.down
    remove_column :users, :newsletter_format
  end
end
