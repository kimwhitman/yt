class AddLastLoginDateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_date, :datetime
  end

  def self.down
    remove_column users, :last_login_date
  end
end
