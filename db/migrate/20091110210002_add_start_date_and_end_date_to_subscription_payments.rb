class AddStartDateAndEndDateToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :start_date, :date
    add_column :subscription_payments, :end_date, :date
  end

  def self.down
    remove_column :subscription_payments, :end_date
    remove_column :subscription_payments, :start_date
  end
end
