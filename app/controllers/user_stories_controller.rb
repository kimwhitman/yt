class UserStoriesController < ApplicationController

  def new
    @user_story = UserStory.new
  end

  def create
    @user_story = UserStory.new params[:user_story]
    location = [params[:city], params[:state], params[:country]].compact
    @user_story.location = location.join(', ')
    name = params[:last_name].empty? ? params[:first_name] : params[:first_name] + " " + params[:last_name]
    @user_story.name = name

    if @user_story.save
      render :action => 'thank_you'
    else
      render :action => 'new'
    end
  end

  def index
    unless params[:all_stories] == true.to_s
      @user_stories = UserStory.published.paginate(:all, :order => 'publish_at DESC', :page => (params[:page] || 1), :per_page => 5)
    else
      @user_stories = UserStory.published.by_publish_at
    end
  end

  def show
    @user_story = UserStory.published.find_by_id(params[:id])
    render(:action => 'not_found') and return unless @user_story
    params[:all_stories] == true
    @user_stories = [@user_story]
    render :action => 'index'
  end
end
