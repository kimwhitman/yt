class ReviewsController < ApplicationController
  def create
    @video = Video.find(params[:video_id])
    review = @video.reviews.build params[:review]
    review.is_public = true
    review.score = params[:review_score].to_i > 0 ? params[:review_score] : 0
    review.user_id = current_user.id
    if logged_in?
      review.save
    end
    respond_to do |format|
      format.html { redirect_to video_url(@video) }
      format.js
    end
  end

  def destroy
  	@video = Video.find(params[:video_id])
  	@review = @video.reviews.find(params[:id])
  	if current_user.id == @review.user_id
  		@review.destroy
  	end
  end
end
