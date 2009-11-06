class Admin::MediaKitsController < Admin::BaseController
  active_scaffold :media_kits do |config|
    config.label = "Media Downloads"
    list_or_show_columns = [:name, :media_kit_type, :dimensions, :image, :rank]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns
    config.list.sorting = { :name => :asc }
    config.create.multipart = true
    config.update.multipart = true
    create_or_update_columns = [:name, :media_kit_type, :dimensions, :image, :rank]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end
end
