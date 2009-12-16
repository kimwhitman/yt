class Admin::UserStoriesController < Admin::BaseController
  active_scaffold :user_stories do |config|
    config.list.sorting = { :publish_at => :desc}

    config.actions.exclude :create
    display_columns = [:status, :title, :story, :name, :location, :email, :personal_message, :image, :created_at, :published_at]
    config.columns = display_columns
    config.columns[:status].sort_by :sql => "publish_at"
    config.columns[:published_at].sort_by :sql => "publish_at"
    config.list.columns = display_columns
    config.show.columns = display_columns
    config.update.multipart = true
    config.update.columns = [:is_public, :title, :story, :name, :location, :email, :personal_message, :image, :publish_at]
    config.columns[:is_public].description = "<span style='font-size: 14px; color: #333333;'>Publish this story (This story will not be displayed unless it is published)</span>"

    #display_columns = [:title, :content, :user, :video, :is_public, :created_at]
    #config.list.columns = display_columns
    #config.show.columns = display_columns
    #create_or_update_columns = [:is_public]
    #config.update.columns = create_or_update_columns
  end

  before_filter :setup_story_type
  before_filter :set_default_personal_message, :only => [:edit, :new]
  after_filter :announce_published, :only => :update

  def remove_image
    user_story = UserStory.find(params[:record])
    user_story.image = nil
    user_story.save
    respond_to do |wants|
      wants.js {
        render(:update) do |page|
          page.remove "paperclip_#{user_story.id}"
          page.remove "delete_link"
        end
      }
    end
  end

  protected

  def setup_story_type
    @story_type = params[:story_type] || 'all'
    case @story_type
    when 'published'
      active_scaffold_config.list.label = "Published User Stories"
    when 'unpublished'
      active_scaffold_config.list.label = "Unpublished User Stories"
    when 'all'
      active_scaffold_config.list.label = "All User Stories"
    end
  end

  def set_default_personal_message
    user_story = UserStory.find(params[:id])
    if user_story.personal_message.blank?
      user_story.personal_message = File.open("#{RAILS_ROOT}/app/views/admin/user_stories/personal_message.txt", "r") {|f| f.read}
      user_story.save
    end
  end

  def announce_published
    user_story = UserStory.find(params[:id])
    if (!user_story.has_announced_publish && user_story.is_public)
      user_story.has_announced_publish = true
      user_story.save
      UserMailer.deliver_user_story_published(user_story)
    end
  end

  def conditions_for_collection
    case @story_type
    when 'published'
      'publish_at IS NOT NULL'
    when 'unpublished'
      'publish_at IS NULL'
    when 'all'
      'publish_at IS NULL OR publish_at IS NOT NULL'
    end
  end

  def after_create_save(record)
    expire_action "pages/home"
  end

  def after_update_save(record)
    expire_action "pages/home"
  end
end
