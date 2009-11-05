class Admin::GetStartedTodaysController < Admin::BaseController
  active_scaffold :get_started_todays do |config|
    list_or_show_columns = [:heading, :content, :image, :rank, :link]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns
    config.list.sorting = { :heading => :asc }
    config.create.multipart = true
    config.update.multipart = true
    create_or_update_columns = [:heading, :content, :image, :rank, :link]
    config.columns[:link].description = "if no link is provided, then the image will direct the user to sign-up or billing depending on their log in status."
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end
end