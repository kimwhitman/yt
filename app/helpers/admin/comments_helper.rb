module Admin::CommentsHelper
  def status_column(record)
    if record.is_public
      "<span style='color: #990000;'>Published</span>"
    else
      "Unpublished"
    end
  end

  def content_column(record)
    h(truncate(record.content, 120))
  end
end
