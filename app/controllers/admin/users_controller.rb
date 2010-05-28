class Admin::UsersController < Admin::BaseController
  active_scaffold :users do |config|
      list_columns = edit_columns = [:name, :photo, :email, :city, :state, :country, :wants_newsletter, :membership_type]
      edit_columns.delete(:membership_type)
      config.list.columns = list_columns
      config.show.columns = list_columns
      config.update.columns = edit_columns
      config.update.multipart = true
      config.actions.exclude  :create
    end

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
    @users = User.paginate(:all, :page => params[:page], :per_page => 100,
      :include => { :account => { :subscription => :subscription_plan } },
      :order => 'created_at DESC')
  end
end
