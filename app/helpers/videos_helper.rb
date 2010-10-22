module VideosHelper
  def select_all_or_cancel_links(opts = {})
    opts.reverse_merge! :clear_text => 'clear',
      :select_text => 'show all',
      :context => 'this'
    html = ''
    html << link_to_function(opts[:clear_text], "$('input[type=checkbox]', #{opts[:context]}).attr('checked', false);")
    html << "&nbsp;|&nbsp;"
    html << link_to_function(opts[:select_text], "$('input[type=checkbox]', #{opts[:context]}).attr('checked', true);")
    html
  end

  # This method looks identical to the above;
  # however, it is designed to work with the toggle_filter javascript
  # function on the search page (VideosController#index)
  # Also deals with subgroups (specifically the focus controller)
  def clear_or_show_all(opts = {})
    opts.reverse_merge! :clear_text => 'clear',
      :show_all_text => 'show all',
      :context => 'this'
    set_check = Proc.new { |checked| "$('.filter_options.nested input:checkbox, input.header_checkbox', $('#{opts[:context]}')).attr('checked', #{checked});" }
    expand_nodes = "$('#{opts[:context]}').prev().click(); $('.filter_option_box.hidden', $('#{opts[:context]}')).click();"
    html = ''
    html << link_to_function(opts[:clear_text], set_check.call(false))
    html << "&nbsp;|&nbsp;"
    html << link_to_function(opts[:show_all_text], "#{set_check.call(true)} #{expand_nodes}" )
  end

  def is_searched_for?(name, value)
    search = params[:search] || params.except(:action, :controller, :format)
    values = search[name]
    if values
      case values
      when Array
        values.include?(value) || values.include?(value.to_s)
      else
        values == value || values == value.to_s
      end
    else
      false
    end
  end

  def video_search_url(options = {})
    search_videos_path(options)
  end

  def link_to_video(video, options = {})
    opts = options.dup
    path = opts.delete(:url) || video_path(video)
    opts.reverse_merge! :title => "More about #{video.title}"
    unless opts[:dont_show_free].to_s == "true"
      link_content = opts.delete(:text) || <<-EOF
      #{content_tag(:div, image_tag('freeClassIcon_resultsThumbnail.png', :border => 0, :style => 'width:100%'), :id => 'free_video') if video.free?}
        #{image_tag(video.thumbnail_url.to_s, :size => '140x78', :border => 0, :alt => "More about #{video.title}")}
      EOF
    else
      link_content = opts.delete(:text) || <<-EOF
        #{image_tag(video.thumbnail_url, :size => '140x78', :border => 0, :alt => "More about #{video.title}")}
      EOF
    end
    link_to link_content, path, opts
  end

  def video_icon_class(video)
    return 'free' if video.free?
    return 'studio_sessions' if video.tags.downcase.split(',').each { |tag| tag.strip }.include?('studio session')
    return 'new'
  end
end
