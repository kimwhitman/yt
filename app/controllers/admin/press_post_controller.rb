class Admin::PressPostController < Admin::BaseController
  active_scaffold :press_posts do |config|
    list_or_show_columns = [:active, :rank, :title, :body, :date_posted]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns + [:photo]
    config.list.sorting = { :created_at => :desc }
    config.create.multipart = true
    config.update.multipart = true
    create_or_update_columns = [:active, :rank, :title, :date_posted, :url, :url_title, :intro, :body, :photo, :caption]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end
end
