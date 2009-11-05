class Admin::BaseController < ActionController::Base
  include AuthenticatedSystem   # EAE
  layout 'admin'
  helper Admin::BaseHelper
  #include ExceptionNotifiable
  before_filter :must_be_admin    # EAE
  before_filter :default_paging
  ActiveScaffold.set_defaults do |config|
    config.actions.exclude :nested
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end

  protected

  def default_paging
    @page = params[:page] || 1
    @per_page = params[:per_page] || 20
  end

  def must_be_admin     #EAE
    unless logged_in? && current_user.admin?
      redirect_to("/")
    end
  end

  #EAE copied from ApplicationController - not me
  # This works around some fucked-up weird problem that only happens
  # in development mode.
  # When you reference 'User' in AuthenticatedSystem
  # It won't let get unloaded from memory, and generates errors up the ass.
  def user_class
    User
  end
end
