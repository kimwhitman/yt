class CommentsController < ApplicationController
  def create
    @video = Video.find(params[:video_id])
    @comment = @video.comments.build params[:comment]
    @comment.is_public = true
    @comment.user_id = current_user.id
    if logged_in?
      @comment.save
    end
    respond_to do |format|
      format.html { redirect_to video_url(@video) }
      format.js
    end
  end
  def destroy
  	@video = Video.find(params[:video_id])
  	@comment = @video.comments.find(params[:id])
  	if current_user.id == @comment.user_id
  		@comment.destroy
  	end
  end
end
