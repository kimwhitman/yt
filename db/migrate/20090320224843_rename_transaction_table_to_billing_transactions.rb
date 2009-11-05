class RenameTransactionTableToBillingTransactions < ActiveRecord::Migration
  def self.up
    rename_table :transactions, :billing_transactions
  end

  def self.down
    rename_table :billing_transactions, :transactions
  end
end
