require "test_helper"

class GoogleSignInTest < ActionDispatch::IntegrationTest
  test "signing in via Google creates a user, sets session, and redirects to profile" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456",
      info: {
        email: "person@example.com",
        name: "Test Person",
        image: "https://example.com/avatar.png"
      }
    })

    assert_difference "User.count", 1 do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to profile_path
    user = User.find_by(provider: "google_oauth2", uid: "123456")
    assert_equal user.id, session[:user_id]
  end

  test "signing out clears the session and redirects home" do
    user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name, image: user.avatar_url }
    })
    get "/auth/google_oauth2/callback"

    delete logout_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end
