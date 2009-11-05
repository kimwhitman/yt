module Admin::EventsHelper
  def asset_form_column(event, name)
    html = ''
    html << link_to_paperclip(event.asset) if event.asset?
    html << '<br/>' if event.asset?
    html << file_field_tag(name)
  end

  def asset_column(event)
    event.asset? ? (image_tag event.asset.url, :width => "75") : "No Asset"
  end

  def date_range_column(event)
    "#{event.begin_date.strftime('%m/%d/%y')} -- #{event.end_date.strftime('%m/%d/%y')}"
  end

  def begin_date_form_column(event, name)
    calendar_date_select :record, :begin_date, :popup => 'force', :time => false
  end

  def end_date_form_column(event, name)
    calendar_date_select :record, :end_date, :popup => 'force', :time => false
  end
end
