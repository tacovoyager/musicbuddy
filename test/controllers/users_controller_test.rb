require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "redirects to root when not logged in" do
    get profile_path
    assert_redirected_to root_path
  end

  test "renders successfully when logged in" do
    user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name, image: user.avatar_url }
    })
    get "/auth/google_oauth2/callback"

    get profile_path

    assert_response :success
    assert_select "h2", user.name
  end
end
