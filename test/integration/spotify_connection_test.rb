require "test_helper"

class SpotifyConnectionTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: @user.provider,
      uid: @user.uid,
      info: { email: @user.email, name: @user.name, image: @user.avatar_url }
    })
    get "/auth/google_oauth2/callback"
  end

  teardown do
    OmniAuth.config.mock_auth[:spotify] = nil
  end

  test "connecting Spotify creates a spotify_account for the current user" do
    OmniAuth.config.mock_auth[:spotify] = OmniAuth::AuthHash.new({
      provider: "spotify",
      uid: "spotify-uid-1",
      info: { name: "Test Person", email: "person@example.com" },
      credentials: {
        token: "access-token",
        refresh_token: "refresh-token",
        expires_at: 1.hour.from_now.to_i,
        scope: "user-read-email"
      }
    })

    assert_difference "SpotifyAccount.count", 1 do
      get "/auth/spotify/callback"
    end

    assert_redirected_to profile_path
    assert_equal "spotify-uid-1", @user.reload.spotify_account.uid
    assert_equal "access-token", @user.spotify_account.access_token
  end

  test "disconnecting Spotify destroys the spotify_account" do
    @user.spotify_account_from_omniauth(OmniAuth::AuthHash.new({
      credentials: { token: "access-token", refresh_token: "refresh-token", expires_at: 1.hour.from_now.to_i, scope: "user-read-email" }
    }).tap { |a| a.uid = "spotify-uid-1" })

    assert_difference "SpotifyAccount.count", -1 do
      delete disconnect_spotify_path
    end

    assert_redirected_to profile_path
    assert_nil @user.reload.spotify_account
  end
end
