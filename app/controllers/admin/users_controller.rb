class Admin::UsersController < Admin::BaseController
  active_scaffold :users do |config|
    list_columns = edit_columns = [:name, :photo, :email, :city, :state, :country, :wants_newsletter, :membership_type, :points_current]
    edit_columns.delete(:membership_type)
    config.list.columns = list_columns
    config.show.columns = list_columns
    config.update.columns = edit_columns
    config.update.multipart = true
    config.actions.exclude  :create
  end

  before_filter :show_search
  before_filter :fetch_user, :only => [:show, :cancel_subscription]

  def remove_photo
    user = User.find(params[:record])
    user.photo = nil
    user.save
    respond_to do |wants|
      wants.js {
        render(:update) do |page|
          page.remove "paperclip_#{user.id}"
          page.remove "delete_link"
        end
      }
    end
  end

  def index
    order = params[:order] || 'created_at'
    if params[:desc]
      descending = params[:desc] == 'true' ? 'DESC' : 'ASC'
    else
      descending = 'DESC'
    end

    @users = User.paginate(:all, :page => params[:page], :per_page => 100,
      :include => { :account => { :subscription => :subscription_plan } },
      :order => "IF(ISNULL(#{ order }),1,0), #{ order } #{ descending }")
  end

  def show
    @subscription_payments = @user.account.subscription.subscription_payments
    @subscription_billing_transactions = @user.account.subscription.billing_transactions
    @purchases = @user.purchases
    @purchase_billing_transactions = @user.purchases.collect(&:billing_transaction).flatten.compact
  end

  def cancel_subscription
    @user.account.subscription.downgrade_to_free
    flash[:success] = "This user's subscription has been cancelled and they now have a Free subscription"
    redirect_to admin_user_path(@user)
  end



  private

    def fetch_user
      @user = User.find(params[:id])
    end

    def show_search
      @show_search = true
    end
end
