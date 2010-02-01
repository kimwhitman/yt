require 'test_helper'

# TODO: Add tests for authenticated users
class PlaylistsControllerTest < ActionController::TestCase

  def setup
    stub_rest_client

    @sample_video = Video.create!(:title => "Sample Video",
      :duration           => 1.hour,
      :is_public          => true,
      :streaming_media_id => 1111,
      :description        => "Sample Description")

    @video_not_in_user_playlist = Video.create!(:title => "Sample Video", :duration => 1.hour,
      :is_public          => true,
      :streaming_media_id => 1111,
      :description        => "Sample Description")

      @request.session[:temp_playlist] = UserPlaylist.new
  end

  def test_remove_video
    @request.session[:temp_playlist].add(@sample_video)

    assert_equal 1, @request.session[:temp_playlist].size

    assert_difference '@request.session[:temp_playlist].size', -1 do
      post :remove, {"video_id" => @sample_video.id, :format => "js"}
    end
  end

  def test_remove_video_not_in_playlist
    @request.session[:temp_playlist].add(@sample_video)

    assert_equal 1, @request.session[:temp_playlist].size

    assert_no_difference '@request.session[:temp_playlist].size' do
      post :remove, {"video_id" => @video_not_in_user_playlist.id, :format => "js"}
    end
  end

  def test_remove_non_existent_video
    @request.session[:temp_playlist].add(@sample_video)

    assert_no_difference '@request.session[:temp_playlist].size' do
      post :remove, {"video_id" => 'non-existent', :format => "js"}
    end
  end
end
