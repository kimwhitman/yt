class Admin::AnalyticsController < Admin::BaseController

  def index
    # Get most recent subscription payments for a subscription that are later than 30 days -- that means the user never renewed their subscription.
    # HACK MAGIC: 1 == free, must deploy now.
    @cancelled_subscriptions = SubscriptionPayment.count(:joins => [:subscription], :group => 'subscription_id', :order => 'subscription_payments.created_at DESC', :conditions => "subscription_payments.created_at > '#{30.days.ago}' OR subscription_plan_id = 1").inject(0) { |sum, a| sum += a.last }
    @total_active_subscriptions = Subscription.count(:conditions => { :subscription_plan_id => SubscriptionPlan.find_by_name('Premium') })

    @last_month_subscribers = SubscriptionPayment.count(:conditions => { :created_at => (2.months.ago..1.month.ago) }, :group => 'subscription_id').inject(0) { |sum, a| sum += a.last}
    @this_month_subscribers = SubscriptionPayment.count(:conditions => { :created_at => (1.months.ago..DateTime.now) }, :group => 'subscription_id').inject(0) { |sum, a| sum += a.last}
  end

  def sales_by_user
    @purchases = Purchase.paginate(:all, :conditions => "user_id IS NOT NULL", :page => @page, :per_page => @per_page)
  end

  def sales_by_episode
    @videos = Video.paginate(:select => "videos.*, (SELECT COUNT(*) FROM purchase_items WHERE purchase_type = 'video' AND purchased_item_id = videos.id) as purchase_cnt",
      :order => 'purchase_cnt desc',
      :page => @page, :per_page => @per_page)
  end

  def subscribers
    @users = User.paginate(:select => "users.*",
      :joins => "INNER JOIN accounts ON accounts.id = `users`.account_id INNER JOIN subscriptions ON subscriptions.account_id = accounts.id INNER JOIN subscription_payments ON subscription_payments.subscription_id = subscriptions.id",
      :order => 'users.email',
      :page => @page, :per_page => @per_page)
  end

  def ambassador_referrals
    order = params[:order] || 'points_earned DESC, free_conversions DESC'
    if params[:desc]
      descending = params[:desc] == 'true' ? 'DESC' : 'ASC'
    end

    @ambassadors = User.ambassadors.paginate(:select =>
      "users.*, (SELECT COUNT(ambassador_users.id) FROM users AS ambassador_users
        INNER JOIN accounts ON accounts.id = ambassador_users.account_id
        INNER JOIN subscriptions ON subscriptions.account_id = accounts.id
        INNER JOIN subscription_plans ON subscription_plan_id = subscription_plans.id
        WHERE subscription_plans.name = 'Free'
        AND ambassador_users.ambassador_id = users.id
      ) AS free_conversions,
      (SELECT COUNT(share_url_redirects.id) FROM share_url_redirects
        INNER JOIN share_urls ON share_urls.id = share_url_redirects.share_url_id
        WHERE share_urls.user_id = users.id) AS visits",
      :joins => "INNER JOIN accounts ON accounts.id = users.account_id
        INNER JOIN subscriptions ON subscriptions.account_id = accounts.id
        INNER JOIN subscription_plans ON subscription_plan_id = subscription_plans.id",
      :order => "#{order} #{descending}", :page => @page, :per_page => @per_page)
  end
end
