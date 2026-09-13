class FetchMusicbuddyPlaylistsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user&.spotify_account

    playlists = user.spotify_account.musicbuddy_playlists
    broadcast_replace(user, partial: "spotify_playlists/musicbuddy_list", locals: { playlists: playlists })
  rescue SpotifyAccount::ApiError => e
    if e.status == 401
      broadcast_replace(user, partial: "spotify_playlists/expired", locals: {})
    else
      broadcast_replace(user, partial: "spotify_playlists/musicbuddy_error", locals: { message: e.message })
    end
  end

  private

  def broadcast_replace(user, partial:, locals:)
    Turbo::StreamsChannel.broadcast_replace_to(
      "spotify_musicbuddy_playlists_#{user.id}",
      target: "musicbuddy_playlists",
      partial: partial,
      locals: locals
    )
  end
end
