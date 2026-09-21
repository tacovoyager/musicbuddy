require "test_helper"

class SpotifyPlaylistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: @user.provider,
      uid: @user.uid,
      info: { email: @user.email, name: @user.name, image: @user.avatar_url }
    })
    get "/auth/google_oauth2/callback"

    @user.create_spotify_account!(uid: "spotify-uid-1", access_token: "token")
  end

  test "index enqueues the Musicbuddy playlists fetch job and renders the loading frame" do
    assert_enqueued_with(job: FetchMusicbuddyPlaylistsJob, args: [ @user.id ]) do
      get spotify_playlists_path
    end

    assert_response :success
    assert_match "musicbuddy_playlists", response.body
  end

  test "index skips enqueueing the job and renders the refresh-token prompt when the token is expired" do
    @user.spotify_account.update!(expires_at: 1.hour.ago)

    assert_no_enqueued_jobs do
      get spotify_playlists_path
    end

    assert_response :success
    assert_match "Refresh your token", response.body
  end

  test "create appends a playlist via turbo stream" do
    playlist = { "id" => "abc123", "name" => "Musicbuddy Mix ABC123", "external_urls" => { "spotify" => "https://open.spotify.com/playlist/abc123" } }

    stub_spotify_account_method(:create_playlist, playlist) do
      post spotify_playlists_path, as: :turbo_stream
    end

    assert_response :success
    assert_match "spotify_playlist_abc123", response.body
    assert_match "Musicbuddy Mix ABC123", response.body
  end

  test "create shows a generic error message when the Spotify API call fails" do
    stub_spotify_account_method(:create_playlist, ->(*) { raise SpotifyAccount::ApiError.new("Spotify API error (500)", status: 500) }) do
      post spotify_playlists_path, as: :turbo_stream
    end

    assert_response :success
    assert_match "Spotify API error (500)", response.body
  end

  test "create shows a reconnect message when the Spotify API call fails with 401" do
    stub_spotify_account_method(:create_playlist, ->(*) { raise SpotifyAccount::ApiError.new("Spotify API error (401)", status: 401) }) do
      post spotify_playlists_path, as: :turbo_stream
    end

    assert_response :success
    assert_match "Your Spotify connection has expired", response.body
  end

  test "destroy removes a playlist via turbo stream" do
    stub_spotify_account_method(:delete_playlist, true) do
      delete spotify_playlist_path("abc123"), as: :turbo_stream
    end

    assert_response :success
    assert_match "spotify_playlist_abc123", response.body
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
