class SpotifyPlaylistsController < ApplicationController
  before_action :require_login
  before_action :require_spotify_account

  def index
    if current_user.spotify_account.expired?
      render partial: "spotify_playlists/expired"
    else
      FetchMusicbuddyPlaylistsJob.perform_later(current_user.id)
    end
  end

  def create
    playlist = current_user.spotify_account.create_playlist(random_playlist_name)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("created-playlists", partial: "spotify_playlists/playlist", locals: { playlist: playlist })
      end
      format.html { redirect_to profile_path }
    end
  rescue SpotifyAccount::ApiError => e
    handle_api_error(e)
  end

  def destroy
    current_user.spotify_account.delete_playlist(params[:id])
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("spotify_playlist_#{params[:id]}") }
      format.html { redirect_to profile_path }
    end
  rescue SpotifyAccount::ApiError => e
    handle_api_error(e)
  end

  private

  def require_spotify_account
    redirect_to profile_path, alert: "Connect your Spotify account first." unless current_user.spotify_account
  end

  def random_playlist_name
    "#{SpotifyAccount::MUSICBUDDY_TERM.capitalize} Mix #{SecureRandom.hex(3).upcase}"
  end

  def handle_api_error(error)
    message = error.status == 401 ? "Your Spotify connection has expired. Reconnect to try again." : error.message
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("created-playlists", partial: "spotify_playlists/error", locals: { message: message }) }
      format.html { redirect_to profile_path, alert: message }
    end
  end
end
