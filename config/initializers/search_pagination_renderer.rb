# A pagination renderer specifically for the videos search page.
# Ignores options[:seperator] and options[:page_links]
class SearchPaginationRenderer < WillPaginate::LinkRenderer
  def to_html
    #links = @options[:page_links] ? windowed_links : []
    links = []
    
    img = Proc.new { |dir, state| "/images/search/#{dir}Arrow_#{state}.png" }
    events = Proc.new { |img_path| "$(this).attr('src', '#{img_path}'); "}
    left_image = @template.image_tag(img.call('left', 'default'),
            :onmouseover => events.call(img.call('left', 'hover')),
            :onmouseout => events.call(img.call('left', 'default'))
    )
    right_image = @template.image_tag(img.call('right', 'default'),
            :onmouseover => events.call(img.call('right', 'hover')),
            :onmouseout => events.call(img.call('right', 'default'))
    )
    links.unshift page_link_or_span(@collection.previous_page, %w(disabled prev_page), left_image)
    links.push    " Page <span class='current'>#{current_page}</span> of <span class='total'>#{total_pages} </span>"
    links.push    page_link_or_span(@collection.next_page,     %w(disabled next_page), right_image)
    
    html = links.join(@options[:separator])
    @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
  end
end