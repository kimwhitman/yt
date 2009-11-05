class Admin::YogaTypesController < Admin::BaseController
  active_scaffold :yoga_types do |config|
    config.list.columns = [:name, :description, :rank]
    config.list.sorting = { :name => :asc }
    create_or_update_columns = [:name, :description, :rank]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
    config.columns[:rank].description = "Use this field to save your sorting preferences"
    config.list.sorting = {:rank => :asc}
  end
end
