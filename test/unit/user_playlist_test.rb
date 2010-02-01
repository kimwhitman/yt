require 'test_helper'

class UserPlaylistTest < ActiveSupport::TestCase
  def setup
    stub_rest_client

    @user = User.create! :email => 'free_user@domain.org',
      :password                => 'password',
      :password_confirmation   => 'password',
      :name => 'Test User'

    @sample_video = Video.create!(:title => "Sample Video",
      :duration           => 1.hour,
      :is_public          => true,
      :streaming_media_id => 1111,
      :description        => "Sample Description")

    @video_not_in_user_playlist = Video.create!(:title => "Sample Video", :duration => 1.hour,
      :is_public          => true,
      :streaming_media_id => '1111',
      :description        => "Sample Description")
  end

  def test_initialize_with_user
    assert_nothing_raised do
      up = UserPlaylist.new(@user)
    end
  end

  def test_initialize_with_nil
    assert_nothing_raised do
      up = UserPlaylist.new
    end
  end

  def test_remove_for_with_playlist
    user_playlist = UserPlaylist.new(@user)

    assert_no_difference('user_playlist.size') do
      assert_equal 0, user_playlist.size
      user_playlist.remove(@sample_video)
    end
  end

  def test_remove_with_nonempty_playlist
    @user.playlist_videos << PlaylistVideo.new(:video => @sample_video)
    @user.save

    user_playlist = UserPlaylist.new(@user)

    assert_difference('user_playlist.size', -1) do
      user_playlist.remove(@sample_video)
    end

    assert_difference('user_playlist.size', 0) do
      user_playlist.remove(@video_not_in_user_playlist)
    end
  end
end
