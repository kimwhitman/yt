class Admin::SiteSearchesController < Admin::BaseController

  def search
    respond_to do |format|
      format.xml do
        render :xml => SiteSearch.admin_search(params[:search_term])
      end
    end
  end

  # the parameter 'object' is sent in the format '66|Fund' or '8870|Stock'
  def select_search_result
    object = params[:object]
    object_id = object.split('|')[0]
    object_type = object.split('|')[1]
    case object_type
      when 'User'
        redirect_to admin_user_path(User.find(CGI::escape(object_id)))
    end
  end

  def view_results
    @objects = SiteSearch.search_for_all(params[:search_term])
  end
end