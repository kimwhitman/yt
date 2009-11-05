class Admin::EventsController < Admin::BaseController
  active_scaffold :events do |config|
    list_or_show_columns = [:active, :rank, :title, :url, :asset, :date_range]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns
    config.list.sorting = { :active => :asc }
    config.create.multipart = true
    config.update.multipart = true
    create_or_update_columns = [:active, :title, :copy, :begin_date, :end_date, :rank, :url, :asset]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end
end
