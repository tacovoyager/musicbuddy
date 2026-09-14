require "test_helper"

class AiChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: @user.provider,
      uid: @user.uid,
      info: { email: @user.email, name: @user.name, image: @user.avatar_url }
    })
    get "/auth/google_oauth2/callback"
  end

  test "create creates user and assistant chat messages and enqueues job" do
    assert_difference("ChatMessage.count", 2) do
      assert_enqueued_with(job: GenerateAiPlaylistJob) do
        post ai_chats_path, params: { prompt: "Recommend jazz songs" }, as: :turbo_stream
      end
    end

    assert_response :success
    assert_match "You", response.body
    assert_match "Musicbuddy AI", response.body
  end

  test "create rejects blank prompt" do
    assert_no_difference("ChatMessage.count") do
      post ai_chats_path, params: { prompt: "   " }, as: :turbo_stream
    end

    assert_response :bad_request
  end

  test "destroy clears chat messages" do
    @user.chat_messages.create!(role: "user", content: "Test")

    delete ai_chat_path(1), as: :turbo_stream

    assert_response :success
    assert_equal 0, @user.chat_messages.count
  end
end
