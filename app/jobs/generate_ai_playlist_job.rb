# frozen_string_literal: true

class GenerateAiPlaylistJob < ApplicationJob
  queue_as :default

  def perform(user_id:, session_id:, assistant_message_id:)
    user = User.find_by(id: user_id)
    assistant_message = ChatMessage.find_by(id: assistant_message_id)
    return unless user && assistant_message

    api_key = fetch_api_key
    unless api_key.present?
      error_msg = "Anthropic API key is missing. Please set ANTHROPIC_API_KEY in environment or credentials."
      assistant_message.update!(content: error_msg)
      broadcast_message(user, assistant_message, content: error_msg)
      return
    end

    client = Anthropic::Client.new(api_key: api_key)
    full_text = +""

    model_name = ENV.fetch("ANTHROPIC_MODEL", "claude-sonnet-4-5-20250929")

    stream = client.messages.stream(
      model: model_name,
      system: AiSystemPrompt::SYSTEM_INSTRUCTIONS,
      messages: AiSystemPrompt.build_messages(user, session_id: session_id),
      max_tokens: 2048
    )

    stream.each do |event|
      if event.respond_to?(:delta) && event.delta.respond_to?(:text) && event.delta.text.present?
        full_text << event.delta.text
        broadcast_message(user, assistant_message, content: full_text)
      end
    end

    full_text = stream.accumulated_text if full_text.blank? && stream.respond_to?(:accumulated_text)

    assistant_message.update!(content: full_text)
    broadcast_message(user, assistant_message, content: full_text)

    process_playlist_generation(user, full_text)
  rescue StandardError => e
    error_content = "Sorry, an error occurred while processing your request: #{e.message}"
    assistant_message&.update!(content: error_content)
    broadcast_message(user, assistant_message, content: error_content) if user && assistant_message
  end

  private

  def fetch_api_key
    ENV["ANTHROPIC_API_KEY"].presence || Rails.application.credentials.dig(:anthropic, :api_key)
  end

  def broadcast_message(user, message, content:)
    Turbo::StreamsChannel.broadcast_replace_to(
      "ai_chat_#{user.id}",
      target: "chat_message_#{message.id}_content",
      partial: "ai_chats/message_content",
      locals: { message: message, content: content }
    )
  end

  def process_playlist_generation(user, text)
    json_match = text.match(/```json\s*(\{.*?\})\s*```/m)
    return unless json_match

    data = JSON.parse(json_match[1]) rescue nil
    return unless data.is_a?(Hash) && data["tracks"].is_a?(Array) && data["tracks"].any?

    spotify = user.spotify_account
    return unless spotify && !spotify.expired?

    playlist_name = data["playlist_name"].presence || "Musicbuddy AI Mix"
    uris = []

    data["tracks"].each do |item|
      next unless item.is_a?(Hash) && item["title"].present?
      query = "#{item['title']} #{item['artist']}".strip
      track = spotify.search_track(query)
      uris << track["uri"] if track && track["uri"].present?
    end

    return if uris.empty?

    created_playlist = spotify.create_playlist(playlist_name)
    spotify.add_tracks_to_playlist(created_playlist["id"], uris)

    Turbo::StreamsChannel.broadcast_append_to(
      "ai_chat_#{user.id}",
      target: "chat_messages_list",
      partial: "ai_chats/playlist_card",
      locals: { playlist: created_playlist, track_count: uris.size }
    )

    playlists = spotify.musicbuddy_playlists
    Turbo::StreamsChannel.broadcast_replace_to(
      "spotify_musicbuddy_playlists_#{user.id}",
      target: "musicbuddy_playlists",
      partial: "spotify_playlists/musicbuddy_list",
      locals: { playlists: playlists }
    )
  rescue SpotifyAccount::ApiError => e
    Rails.logger.error("Spotify API error during AI playlist creation: #{e.message}")
  end
end
