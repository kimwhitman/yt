# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  REQUIRED_SCRIPTS = []
  def flash_notices
    [:notice, :error].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }
  end

  def breadcrumb(*links)
    html = []
    html << link_to("Home", root_path)
    links.each do |link|
      if link.class == Array.new.class
        if link[1].nil?
          html << link[0]
        else
          html << link_to(link[0], link[1])
        end
      else
        html << link
      end
    end
    return "<div class='arial11_bold_gray' id='navigation'>#{html.join(" : ")}</div>"
  end


  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit')
  end

  def title(page_title)
    content_for(:title) { "Yoga Today - #{page_title}" }
  end

  def required_scripts(*args)
    REQUIRED_SCRIPTS << [*args]
    REQUIRED_SCRIPTS.flatten!
    REQUIRED_SCRIPTS.uniq!
    content_for(:required_scripts) { javascript_include_tag(*REQUIRED_SCRIPTS) }
  end

  def display_video(video, auto_play = false)
    media_id = video.preview_media_id
    if auto_play
      auto_play_flashvars = '&autoplay=true'
    else
      auto_play_flashvars = ''
    end
    if video.free? && logged_in?
        media_id = video.streaming_media_id
    elsif logged_in? && current_user.has_paying_subscription?
      media_id = video.streaming_media_id
    end
    # Embed is deprecated -- why did I use it here?!
    object_opts = {
      :name => 'delve_player_embed_name',
      :id => 'delve_player_embed',
      :width => "100%",
      :height => "100%",
      :type => 'application/x-shockwave-flash',
      :data => 'http://assets.delvenetworks.com/player/loader.swf',
    }
    param_opts = {
      :wmode => 'opaque',
      :movie => "http://assets.delvenetworks.com/player/loader.swf",

      :allowScriptAccess => "always",
      :allowFullScreen => 'true',
      :flashvars => "mediaId=#{media_id}&allowHttpDownload=true&playerForm=f2dfe9b43972411ca10826cb5779f82b#{auto_play_flashvars}",
    }
    content_tag('div', :class => 'video_player') do
      content_tag('object', object_opts) do
        param_opts.collect { |k, v| tag('param', :name => k, :value => v) }.join('')
      end
    end
  end
  # Output an <abbr /> tag to be used with jquery.timeago
  # Options:
  # The following options are off-limits:
  # => title - will be set to the *time* parameter.
  # => class - will be set to 'timeago'
  def time_ago(time, options = {})
    options.reverse_merge! :class => 'timeago',
      :default_text => (distance_of_time_in_words(time, Time.now) + " ago").gsub("about ", ''),
      :title => time.getutc.iso8601,
      :mf => true
    tag = options.delete(:mf) ? :abbr : :span
    content_tag(tag, options.delete(:default_text), options)
  end

  # Helper that outputs an <a /> pointing to root_path with the text 'Home'
  def link_to_home
    link_to 'Home', root_path
  end
  # Spit out a series of styled <img /> tags that represent
  # a score in the range 0-5.
  # A score can only be x.0 or x.5
  def render_star_rating(score, opts = {})
    raise ArgumentError.new("Score is not within 0-5") unless (0..5).include? score
    raise ArgumentError.new("Score is not x.0 or x.5!") unless [0.0, 0.5].include? score % 1.0
    metadata = { 'split' => 2 }
    metadata.merge! opts.delete(:metadata) if opts[:metadata]
    metadata = metadata.collect { |k,v| "#{k}:#{v}" }.join(',')
    opts.reverse_merge! :class => "star {#{escape_javascript(metadata)}}",
      :disabled => true, :name => "readonly_rating_#{(rand.round(5) * 10000).round}"
    scores = (1..5).inject([]) { |memo, i| memo << [i - 0.5, i] }.flatten
    html = ''
    scores.each { |val| html << radio_button_tag(opts[:name], val, score.to_f == val, opts.except(:name)) }
    html
  end

  def star_rating_input(opts = {})
    metadata = { }
    metadata.merge! opts.delete(:metadata) if opts[:metadata]
    metadata = metadata.collect { |k,v| "#{k}:#{v}" }.join(',')
    css_class = if metadata
      "star {#{escape_javascript(metadata)}}"
    else
      'star'
    end
    opts.reverse_merge! :class => css_class, :name => 'rating'
    html = ''
    (1..5).each { |i| html << radio_button_tag(opts[:name], i, false, opts.except(:name))  }
    html
  end

  def current_url_for(opts = {})
    params.merge opts
  end

  def user_photo_image(user, options = {})
    opts = options.reverse_merge :class => 'user_avatar'
    path = user.nil? ? 'user_yogi.png' : user.photo.url
    image_tag path, opts
  end
  # TODO
  # The following code is required so we can use regular helpers inside of RJS contexts
  # see ShoppingCartHelper#update_cart as an example.
  def context
    page.instance_variable_get("@context").instance_variable_get("@template")
  end

  def countries
    ["", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antigua", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Barbuda", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bonaire", "Botswana", "Brazil", "British Virgin isl.", "Brunei", "Bulgaria", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Rep.", "Chad", "Channel Islands", "Chile", "China", "Colombia", "Congo", "Cook Islands", "Costa Rica", "Croatia", "Curacao", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Faeroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Great Britain", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Irak", "Iran", "Ireland", "Ireland, Northern", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Kyrgyzstan", "Latvia", "Lebanon", "Liberia", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar/Burma", "Namibia", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Rwanda", "Saba", "Saipan", "Saudi Arabia", "Scotland", "Senegal", "Seychelles", "Sierra Leone", "Singapore", "Slovak Republic", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tanzania", "Thailand", "Togo", "Trinidad-Tobago", "Tunisia", "Turkey", "Turkmenistan", "United Arab Emirates", "U.S. Virgin Islands", "United States", "Uganda", "United Kingdom", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Wales", "Yemen", "Zaire", "Zambia", "Zimbabwe"]
  end

  def states
    ["", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
  end

  def social_share_url(url, site = :facebook, title = "Yoga Today - Yoga Delivered Today")
    url = CGI::escape(url)
    title = CGI::escape(title)

    case site
      when :facebook : "http://www.facebook.com/sharer.php?u=#{url}&t=#{title}"
      when :delicious : "http://del.icio.us/post?url=#{url}&title=#{title}"
    end
  end
end
