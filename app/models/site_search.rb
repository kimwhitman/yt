class SiteSearch

  # Returns records in an XML format that is required by the BSN jQuery autocompleter
  def self.admin_search(search_term)
    results = Array.new
    results_count = 0
    @users_limit = 5
    @users = []
    @users_transactions = []

    find_users(search_term)
    @users.each do |user|
      results_count += 1
      results << "<rs id=\"#{ user.id }|User\" info=\"USER --
        Subscription:#{ user.subscription_plan_name }
        #{ ' -- AmbassadorID:' + user.ambassador_name if user.ambassador_name }\">#{ user.name } - #{ user.email }</rs>"
    end

    if search_term.to_i > 0
      find_subscription_transactions(search_term)
      @users_transactions.each do |user|
        results_count += 1
        results << "<rs id=\"#{ user.id }|User\" info=\"TRANSACTION --
          ID:#{ BillingTransaction.find_by_authorization_code(search_term).authorization_code } Type:Subscription
          \">#{ user.name } - #{ user.email }</rs>"
      end

      find_purchase_transactions(search_term)
      @users_transactions.each do |user|
        results_count += 1
        results << "<rs id=\"#{ user.id }|User\" info=\"TRANSACTION --
          ID:#{ BillingTransaction.find_by_authorization_code(search_term).authorization_code } Type:Purchase
          \">#{ user.name } - #{ user.email }</rs>"
      end
    end

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results>#{ results }</results>"
  end

  def self.find_subscription_transactions(search_term)
    unless search_term.blank?
      search_term = search_term.sanitize
      @users_transactions = User.find(:all,
        :joins => "INNER JOIN accounts ON accounts.id = users.account_id
          INNER JOIN subscriptions ON subscriptions.account_id = accounts.id
          INNER JOIN billing_transactions ON billing_transactions.billing_id = subscriptions.id AND billing_transactions.billing_type = 'Subscription'",
        :conditions => ["authorization_code = ?", search_term],
        :limit => 10)
    end
  end

  def self.find_purchase_transactions(search_term)
    unless search_term.blank?
      search_term = search_term.sanitize
      @users_transactions = User.find(:all,
        :joins => "INNER JOIN purchases ON purchases.user_id = users.id
          INNER JOIN billing_transactions ON billing_transactions.billing_id = purchases.id AND billing_transactions.billing_type = 'Purchase'",
        :conditions => ["authorization_code = ?", search_term],
        :limit => 10)
    end
  end



  private

  def self.find_users(search_term)
    unless search_term.blank?
      search_term = search_term.sanitize
      @users = User.find(:all,
        :include => { :account => { :subscription => :subscription_plan } },
        :conditions => "lower(users.name) LIKE '%#{ search_term.downcase }%' OR lower(email) LIKE '%#{ search_term.downcase }%' OR lower(ambassador_name) LIKE '%#{ search_term.downcase }%'",
        :limit => 10,
        :order => 'users.name')
    end
  end


end