class SiteSearch

  # Returns the top 10 funds matched by name and the top 10 stocks matched by name or symbol
  # in an XML format that is required by the BSN jQuery autocompleter
  def self.admin_search( search_term )
    results = Array.new
    results_count = 0
    @users_limit = 5

    find_users(search_term)

    @users.each do |user|
      results_count += 1
      results << "<rs id=\"#{ user.id }|User\" info=\"User - Subscription:#{ user.account.subscription.subscription_plan.name } Amb. ID:#{ user.ambassador_name }\">#{ user.name } - #{ user.email }</rs>"
    end

    #results << "<rs id=\"#{ search_term }|Results\" info=\"See all results\"> </rs>" unless results_count <= 1
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results>#{ results }</results>"
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