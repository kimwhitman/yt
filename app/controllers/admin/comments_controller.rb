class Admin::CommentsController < Admin::BaseController
  active_scaffold :comments do |config|
    config.list.sorting = { :created_at => :desc}
    config.actions.exclude :create
    display_columns = [:title, :content, :user, :video, :is_public, :offensive, :created_at]
    config.list.columns = display_columns
    config.show.columns = display_columns
    create_or_update_columns = [:title, :content, :offensive, :is_public]
    config.update.columns = create_or_update_columns
  end
end
