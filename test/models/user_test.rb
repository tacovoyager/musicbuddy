require "test_helper"

class UserTest < ActiveSupport::TestCase
  def auth_hash(overrides = {})
    OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "999999",
      info: {
        email: "new@example.com",
        name: "New Person",
        image: "https://example.com/new.png"
      }
    }.deep_merge(overrides))
  end

  test "from_omniauth creates a new user" do
    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth_hash)
      assert_equal "google_oauth2", user.provider
      assert_equal "999999", user.uid
      assert_equal "new@example.com", user.email
    end
  end

  test "from_omniauth is idempotent for the same provider/uid" do
    first_user = User.from_omniauth(auth_hash)

    assert_no_difference "User.count" do
      second_user = User.from_omniauth(auth_hash(info: { name: "Updated Name" }))
      assert_equal first_user.id, second_user.id
      assert_equal "Updated Name", second_user.reload.name
    end
  end
end
