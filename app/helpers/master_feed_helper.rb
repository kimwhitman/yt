module MasterFeedHelper
  def pretty_date_for_xml(timestamp)
    timestamp.strftime('%B %d, %Y')
  end
end
