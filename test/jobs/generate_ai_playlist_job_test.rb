require "test_helper"

class GenerateAiPlaylistJobTest < ActiveJob::TestCase
  setup do
    @user = users(:one)
    @user.create_spotify_account!(uid: "spotify-uid-1", access_token: "token")
    @user_message = @user.chat_messages.create!(role: "user", content: "Create a 2 song playlist", session_id: "s1")
    @assistant_message = @user.chat_messages.create!(role: "assistant", content: "...", session_id: "s1")
  end

  test "perform gracefully handles missing Anthropic API key" do
    job = GenerateAiPlaylistJob.new
    job.define_singleton_method(:fetch_api_key) { nil }

    job.perform(
      user_id: @user.id,
      session_id: "s1",
      assistant_message_id: @assistant_message.id
    )

    assert_match "Anthropic API key is missing", @assistant_message.reload.content
  end
end
