class Admin::InstructorsController < Admin::BaseController
  active_scaffold :instructors do |config|
    list_or_show_columns = [:name, :biography, :photo]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns
    config.list.sorting = { :name => :asc }    
    config.create.multipart = true
    config.update.multipart = true
    create_or_update_columns = [:name, :biography, :photo]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end
end
