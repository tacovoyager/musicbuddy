require "test_helper"

class AiSystemPromptTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.chat_messages.create!(role: "user", content: "Gram Parsons", session_id: "s1")
    @placeholder = @user.chat_messages.create!(role: "assistant", content: "...", session_id: "s1")
  end

  test "build_messages omits the excluded placeholder so history ends with the user turn" do
    messages = AiSystemPrompt.build_messages(@user, session_id: "s1", exclude: @placeholder)

    assert_equal [ { role: "user", content: "Gram Parsons" } ], messages
  end

  test "build_messages includes every message when nothing is excluded" do
    messages = AiSystemPrompt.build_messages(@user, session_id: "s1")

    assert_equal %w[user assistant], messages.map { |m| m[:role] }
  end
end
