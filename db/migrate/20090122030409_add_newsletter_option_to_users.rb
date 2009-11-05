class AddNewsletterOptionToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :wants_newsletter, :default => false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :wants_newsletter
    end
  end
end
