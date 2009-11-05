class Admin::ReviewsController < Admin::BaseController
  active_scaffold :reviews do |config|
    config.list.sorting = { :created_at => :desc}
    config.actions.exclude :create
    display_columns = [:title, :content, :user, :video, :is_public, :created_at]
    config.list.columns = display_columns
    config.show.columns = display_columns    
    create_or_update_columns = [:title, :content, :is_public]    
    config.update.columns = create_or_update_columns
  end
end
