require "test_helper"
require "turbo/broadcastable/test_helper"

class FetchMusicbuddyPlaylistsJobTest < ActiveJob::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @user = users(:one)
    @user.create_spotify_account!(uid: "spotify-uid-1", access_token: "token")
  end

  test "broadcasts matching playlists filtered case-insensitively" do
    playlists = [
      { "name" => "Musicbuddy Mix ABC123" },
      { "name" => "totally unrelated" },
      { "name" => "my MUSICBUDDY favorites" }
    ]

    stub_spotify_account_method(:musicbuddy_playlists, playlists.select { |p| p["name"].downcase.include?("musicbuddy") }) do
      assert_turbo_stream_broadcasts("spotify_musicbuddy_playlists_#{@user.id}", count: 1) do
        FetchMusicbuddyPlaylistsJob.perform_now(@user.id)
      end
    end
  end

  test "broadcasts a generic error state when the Spotify API call fails" do
    stub_spotify_account_method(:musicbuddy_playlists, ->(*) { raise SpotifyAccount::ApiError.new("Spotify API error (500)", status: 500) }) do
      assert_turbo_stream_broadcasts("spotify_musicbuddy_playlists_#{@user.id}", count: 1) do
        FetchMusicbuddyPlaylistsJob.perform_now(@user.id)
      end
    end
  end

  test "broadcasts the expired refresh-token state when the Spotify API call fails with 401" do
    stub_spotify_account_method(:musicbuddy_playlists, ->(*) { raise SpotifyAccount::ApiError.new("Spotify API error (401)", status: 401) }) do
      streams = capture_turbo_stream_broadcasts("spotify_musicbuddy_playlists_#{@user.id}") do
        FetchMusicbuddyPlaylistsJob.perform_now(@user.id)
      end

      assert_equal 1, streams.size
      assert_match "Refresh your token", streams.first.to_s
    end
  end

  private

  def stub_spotify_account_method(method_name, return_value)
    original = SpotifyAccount.instance_method(method_name)
    SpotifyAccount.define_method(method_name) do |*args|
      return_value.respond_to?(:call) ? return_value.call(*args) : return_value
    end
    yield
  ensure
    SpotifyAccount.define_method(method_name, original)
  end
end
