class AddNameFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    # To avoid SLOW validations and callbacks on User, populating columns via SQL
    User.paginated_each(:per_page => 100) do |user|
      ActiveRecord::Base.connection.execute("UPDATE users
        SET first_name = '#{ CGI::escape(user.name.split[0] || '') }', last_name = '#{ CGI::escape(user.name.split[1] || '') }'
        WHERE id = #{ user.id }")
    end
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
