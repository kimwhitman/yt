module PlaylistsHelper
  def add_video_to_playlist_link(text, video, opts = {})
    html_opts = opts.dup
    html_opts.reverse_merge! :class => 'button',
      :id => "#{dom_id(video)}_playlist"
    if user_playlist.has_video?(video)
      return link_to "<strong class='arial11_button_gray'>In Queue</strong>", playlist_path, html_opts
    end
    ajax_opts = {
      :url => url_for(:controller => 'playlists', :action => 'add', :video_id => video.id),
      :method => :put
    }
    link_to_remote text, ajax_opts, html_opts
  end

  def update_playlist
    playlist = page.context.user_playlist
    page.replace_html 'playlist_title', "My Yoga Queue (#{playlist.size})"
    page.replace_html 'playlist_link', "My Yoga Queue (#{playlist.size})"
  end
end
