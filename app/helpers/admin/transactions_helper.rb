module Admin::TransactionsHelper
  def transaction_type_column(transaction)
    transaction.billing_type
  end
  def amount_column(transaction)
    transaction.amount / 100.0
  end
  def items_purchased_column(transaction)
   case transaction.billing_type
      when 'Purchase'
        transaction.billing.purchase_items.count
      when 'Subscription'
        'None'
    end 
  end
  def videos_column(transaction)
    case transaction.billing_type
      when 'Purchase'
        transaction.billing.purchase_items.collect { |pi| pi.name }.join(', ')
      when 'Subscription'
        'All'
    end
  end
  def person_name_column(transaction)
    case transaction.billing_type
      when 'Purchase'
        "#{transaction.billing.first_name} #{transaction.billing.last_name} (#{transaction.billing.email})"
      when 'Subscription'
        user = User.find_by_account_id transaction.billing.account_id
        "#{user.name} (#{user.email})"
    end
  end
end
