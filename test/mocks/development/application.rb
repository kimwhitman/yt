require 'controllers/application'

class ApplicationController < ActionController::Base 
  def ssl_required? 
    false 
  end 

  def current_account
    @current_account ||= Account.find_by_full_domain(request.host) || Account.find(:first)
    raise ActiveRecord::RecordNotFound unless @current_account
    @current_account
  end
end