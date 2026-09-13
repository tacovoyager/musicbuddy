require "test_helper"

class SpotifyAccountTest < ActiveSupport::TestCase
  test "uid must be unique across users" do
    owner = users(:one)
    other = users(:two)
    owner.create_spotify_account!(uid: "dup-uid", access_token: "token-a")

    duplicate = other.build_spotify_account(uid: "dup-uid", access_token: "token-b")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "access_token is encrypted at rest" do
    account = users(:one).create_spotify_account!(uid: "encrypted-uid", access_token: "plain-secret")

    raw_value = SpotifyAccount.connection.select_value(
      "SELECT access_token FROM spotify_accounts WHERE id = #{account.id}"
    )

    assert_not_equal "plain-secret", raw_value
    assert_equal "plain-secret", account.reload.access_token
  end

  test "expired? is false when expires_at is nil" do
    account = users(:one).build_spotify_account(uid: "uid", access_token: "token", expires_at: nil)
    assert_not account.expired?
  end

  test "expired? is false when expires_at is in the future" do
    account = users(:one).build_spotify_account(uid: "uid", access_token: "token", expires_at: 1.hour.from_now)
    assert_not account.expired?
  end

  test "expired? is true when expires_at is in the past" do
    account = users(:one).build_spotify_account(uid: "uid", access_token: "token", expires_at: 1.hour.ago)
    assert account.expired?
  end
end
