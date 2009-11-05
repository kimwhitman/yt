class PlaylistsController < ApplicationController
  verify :method => :put, :only => [:add]
  def add
    @video = Video.find_by_id params[:video_id]
    user_playlist.add(@video)    
  end
  def remove
    @video = Video.find_by_id params[:video_id]
    user_playlist.remove(@video)
    respond_to do |wants|
      wants.js {
        render(:update) do |page|
          page.update_playlist
          page.replace_html "main_content", :partial => 'video', :collection => user_playlist.videos
        end
      }
    end
  end
  def reset
    session[:temp_playlist] = nil
    if logged_in?
      current_user.playlist(true)
    end
    redirect_to request.referer
  end
end
