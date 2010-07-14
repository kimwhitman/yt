class Admin::TransactionsController < Admin::BaseController
  before_filter :show_search

  active_scaffold :billing_transactions do |config|
    config.list.sorting = { :created_at => :desc}
    config.actions.exclude :create, :delete, :update

    display_columns = [:person_name, :amount, :transaction_type, :items_purchased, :authorization_code, :created_at]
    config.list.columns = display_columns
    config.show.columns = display_columns + [:videos]
  end


  private

    def show_search
      @show_search = true
    end

end
