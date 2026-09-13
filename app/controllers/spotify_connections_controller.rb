class SpotifyConnectionsController < ApplicationController
  before_action :require_login

  def create
    current_user.spotify_account_from_omniauth(request.env["omniauth.auth"])
    redirect_to profile_path, notice: "Spotify connected."
  end

  def destroy
    current_user.spotify_account&.destroy
    redirect_to profile_path, notice: "Spotify disconnected."
  end
end
