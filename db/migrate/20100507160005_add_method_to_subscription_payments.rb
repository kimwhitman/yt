class AddMethodToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :payment_method, :string
    add_index :subscription_payments, :payment_method
  end

  def self.down
    remove_column :subscription_payments, :payment_method
    remove_index :subscription_payments, :payment_method
  end
end
