class Admin::VideoFocusController < Admin::BaseController
  active_scaffold :video_focus do |config|
    config.columns = [:name, :description, :video_focus_category, :rank]
    config.columns[:video_focus_category].form_ui = :select
    config.columns[:rank].description = "Use this field to save your sorting preferences"
    config.list.sorting = {:rank => :asc}
  end
end
