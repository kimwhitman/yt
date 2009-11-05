module Admin::BaseHelper
  def title(page_title)
    content_for(:title) { "Yoga Today - #{page_title}" }    
  end

  def link_to_paperclip(paperclip, link_opts = {}, image_opts = {})
    link_opts.reverse_merge! :target => '_blank'
    image_opts.reverse_merge! :width => '64px'
    link_to(image_tag(paperclip.url, image_opts), paperclip.url, link_opts)
  end
  
  def active_scaffold_column_text(column, record)
    if show_all_text?
      clean_column_value(record.send(column.name))
    else
      super(column, record)
    end
  end

  protected

  def show_all_text?
    true
  end
end
