class PagesController < ApplicationController
  before_filter :fetch_ambassador, :only => [:get_started_today, :home]

  def home
    @home_page = true
    @user_story = UserStory.published.by_publish_at(:limit => 1).first
    @featured_videos = FeaturedVideo.previously_featured.by_rank(:include => [:video]).to_a  * 10 # multiply by 10 to create the feel of infinite looping scroll
    @featured_videos_data = @featured_videos.collect do |fv|
      {
        :url => video_path(fv.video), :time => "#{fv.video.duration_to_minutes}:#{fv.video.duration_seconds}",
        :title => fv.video.title, :skill => fv.video.skill_name,
        :instructors => fv.video.instructor_names.join(', '),
        :yoga_types => fv.video.style_names.join(', '),
        :free => fv.free?
      }
    end
  end

  def get_started_today
    @video = Video.fetch_videos_from_brightcove('find_video_by_reference_id', :reference_id => 'YTPROMO')
    @user_story = UserStory.published.by_publish_at(:limit => 1).first
    @billing_cycle = 'Premium Trial'
  end

  def faqs
    # TODO
    @yoga_category = FaqCategory.find_by_name 'Yoga Questions'
    @technical_category = FaqCategory.find_by_name 'Technical Questions'
    @billing_category = FaqCategory.find_by_name 'Billing Questions'
  end

  def instructors
    @instructors = Instructor.all
  end

  def press_and_news
    unless params[:id]
      @posts = PressPost.paginate(:all, :order => 'rank DESC', :conditions => {:active => true}, :page => (params[:page] || 1), :per_page => 10)
    else
      @post = PressPost.find(params[:id])
      render :action => "single_news_article"
    end
  end

  def contact
    return unless request.post?
    ce = ContactEmail.new params
    if ce.valid?
      AdminNotifier.deliver_contact_email ce
      render :action => 'contact_success'
    else
      flash[:contact_error] = "All fields required."
    end
  end

  def media_downloads
    @media_kits = MediaKit.find(:all, :order => 'rank DESC')
    @for_print_media_kits = MediaKit.find(:all, :order => 'rank DESC', :conditions => {:media_kit_type => "For Print"})
    @for_web_media_kits = MediaKit.find(:all, :order => 'rank DESC', :conditions => {:media_kit_type => "For Web"})
    if request.post?
      send_file "#{RAILS_ROOT}/public#{params[:media_kit]}"
    end
  end

  def ask_question
    redirect_to contact_path(:message => params[:message])
  end

  private

  def fetch_ambassador
    if params[:ambassador]
      @ambassador_user = User.find_by_ambassador_name(params[:ambassador])
      cookies[:ambassador_user_id] = @ambassador_user.id.to_s if @ambassador_user
    end

    @ambassador_user = current_user.ambassador if current_user
    cookies[:ambassador_user_id] = params[:ambassador_user_id] if @ambassador_user.nil? && params[:ambassador_user_id]
    @ambassador_user = User.find_by_ambassador_name(params[:ambassador_name]) if @ambassador_user.nil? && params[:ambassador_name]
    @ambassador_user = User.find(cookies[:ambassador_user_id]) if @ambassador_user.nil? && cookies[:ambassador_user_id]

    if current_user && @ambassador_user && current_user.id == @ambassador_user.id
      cookies.delete :ambassador_user_id
      @ambassador_user = nil
    end
  end
end
