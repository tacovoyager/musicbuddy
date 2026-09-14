require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid chat message" do
    msg = @user.chat_messages.build(role: "user", content: "Hello AI")
    assert msg.valid?
  end

  test "requires role and content" do
    msg = ChatMessage.new
    assert_not msg.valid?
    assert_includes msg.errors[:role], "can't be blank"
    assert_includes msg.errors[:content], "can't be blank"
  end

  test "invalid role" do
    msg = @user.chat_messages.build(role: "invalid", content: "Hello")
    assert_not msg.valid?
    assert_includes msg.errors[:role], "is not included in the list"
  end
end
