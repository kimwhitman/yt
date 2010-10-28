class VideosController < ApplicationController
  before_filter :paging_defaults, :only => [:index, :search, :show]

  def brightcove_test
    brightcove = Brightcove::API.new('ctb2F9B1IE23UcaR00CF0QjxvTeMKZGocO1HmQlj4SbNKlo_YoP_ow..')
    response = brightcove.get('find_all_videos',  {:page_size => 10})
    @brightcove_video = response['items'].first
  end


  def index
    #@videos = Video.public.send("by_#{sorting}").paginate(:page => @page, :per_page => @per_page)
    search
  end

  def lineup
    @this_weeks_videos = Video.find_by_sql(["SELECT videos.id, videos.title, skill_level_id, published_at,
      featured_videos.starts_free_at, videos.mds_tags FROM videos LEFT OUTER JOIN `featured_videos` ON featured_videos.video_id = videos.id
      WHERE  (`videos`.`published_at` BETWEEN ? AND ?) OR (featured_videos.starts_free_at BETWEEN ? AND ?)
      ORDER BY (CASE WHEN starts_free_at IS NULL THEN published_at ELSE starts_free_at END) ASC,
      (CASE WHEN starts_free_at IS NULL THEN 2 ELSE 1 END) ASC;",
      Time.zone.now.beginning_of_week, Time.zone.now.end_of_week,
      Time.zone.now.beginning_of_week, Time.zone.now.end_of_week])

    @recently_released_videos = Video.recently_released
    @upcoming_videos = Video.find_by_sql(["SELECT videos.id, videos.title, skill_level_id, published_at,
      featured_videos.starts_free_at, videos.mds_tags FROM videos LEFT OUTER JOIN `featured_videos` ON featured_videos.video_id = videos.id
      WHERE (videos.published_at >= ? OR featured_videos.starts_free_at >= ?)
      ORDER BY (CASE WHEN starts_free_at IS NULL THEN published_at ELSE starts_free_at END) ASC,
      (CASE WHEN starts_free_at IS NULL THEN 2 ELSE 1 END) ASC;",
      Date.today.next_week, Date.today.next_week])

        #Video.after_this_week
  end

  def preview
    render :partial => 'player', :locals => { :video => Video.published.find(params[:id])}
  end

  def info
    render :partial => 'info', :locals => { :video => Video.published.find(params[:id])}
  end


  def this_weeks_free_video
    if free_video_of_week.nil? || free_video_of_week.video.nil?
      flash[:notice] = "We're sorry, it appears that our free video of the week has expired. Please check back soon."
      redirect_to videos_path
    else
      @video = free_video_of_week.video
      render :action => 'show'
    end
  end


  def show
    @sorting = sorting
    @video = Video.published.find(params[:id])
    @preview = params['preview']
    #@preview = true
    session[:continue_shopping_to] = "show"
    session[:last_video_id] = params[:id]

    @related_videos = Video.published.related_videos_for(@video.id).send("by_#{@sorting}").paginate(:page => @page, :per_page => 8).uniq
    respond_to do |format|
      format.html
      format.js do
        render(:update) do |page|
          page.replace 'related_classes', :partial => 'related_videos'
          page << "$('#related_classes input[type=radio].star').rating();"
        end
      end
    end
  end

  def sort_related_videos
    @sorting = sorting
    @video = Video.published.find(params[:id])
    @related_videos = Video.published.related_videos_for(@video.id).send("by_#{@sorting}").paginate(:page => @page, :per_page => 8).uniq
    @display_mode = params[:display_mode]
    respond_to do |wants|
      wants.js {
        render(:update) do |page|
          page.replace 'related_classes', :partial => 'related_videos'
          page << "$('#related_classes input[type=radio].star').rating();"
        end
      }
    end
  end

  # Collection actions
  def search
    @sorting = sorting
    @keywords = (params[:keywords].blank? || params[:keywords].downcase == "keywords") ? nil : params[:keywords]
    if request.post?
      @search_terms = params[:search] || {}
    else
      @search_terms = params.except :controller, :action, :format, :page, :per_page, :keywords
      # Terrible but gets the job done.
      unless params[:search].blank?
        @search_terms = params[:search]
      end
    end
    session[:continue_shopping_to] = "search"
    session[:last_search_params] = @search_terms
    if params[:commit] == 'Search' # keyword search
      @search_terms = {}
      params.delete :search
      @videos = Video.published.send("by_#{@sorting}").keywords(@keywords).paginate(:page => @page, :per_page => @per_page)
    else
      @keywords = ''
      # will_paginate + rails don't do counts right with any "group by" statements.
      total = Video.published.send("by_#{@sorting}").search(@search_terms).count(:group => 'videos.id').size
      @videos = Video.published.send("by_#{@sorting}").search(@search_terms).paginate(:page => @page, :per_page => @per_page, :total_entries => total)
    end
    respond_to do |wants|
      wants.html { render :action => 'index' }
      wants.js do
        render(:update) do |page|
          page.replace_html "x_video_listings", :partial => "video_listings"
          page << "$('input[type=radio].star').rating();"
          page << 'bindSortingDropdown();'
        end
      end
    end
  end

  def leave_suggestion
    @suggestion = Suggestion.new params[:suggestion]
    @suggestion.video_id = params[:id]
    AdminNotifier.deliver_video_suggestion(@suggestion, current_user)
  end

  def mark_as_offensive
    @comment = Comment.find(params[:id])
    @comment.update_attributes(:offensive => true)
    AdminNotifier.deliver_offensive_comment
    respond_to do |wants|
      wants.js {
      render(:update) do |page|
        page.replace_html "offensive_flag_#{@comment.id}", "<br><br><span style='font-weight: bold;'>Thank you. An Email has been sent to an admin to monitor this comment.</span>"
      end
      }
    end
  end

  protected

  def sorting
    params[:sort_by] || 'most_recent'
  end

  def paging_defaults
    @page = params[:page] || 1
    @per_page = params[:per_page] || 20
  end
end
