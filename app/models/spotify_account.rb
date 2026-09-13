class SpotifyAccount < ApplicationRecord
  class ApiError < StandardError
    attr_reader :status

    def initialize(message, status: nil)
      super(message)
      @status = status
    end
  end

  belongs_to :user

  encrypts :access_token, :refresh_token

  validates :uid, presence: true, uniqueness: true
  validates :access_token, presence: true

  API_BASE = "https://api.spotify.com/v1"
  MUSICBUDDY_TERM = "musicbuddy"
  PLAYLISTS_PAGE_SIZE = 50

  def expired?
    expires_at.present? && expires_at.past?
  end

  def create_playlist(name)
    response = connection.post("me/playlists", { name: name }.to_json)
    raise_api_error(response) unless response.success?

    JSON.parse(response.body)
  end

  def delete_playlist(playlist_id)
    response = connection.delete("playlists/#{playlist_id}/followers")
    raise_api_error(response) unless response.success?

    true
  end

  # Spotify's /me/playlists endpoint has no name filter, so pagination + filtering both happen here.
  def playlists
    items = []
    offset = 0

    loop do
      response = connection.get("me/playlists", limit: PLAYLISTS_PAGE_SIZE, offset: offset)
      raise_api_error(response) unless response.success?

      page = JSON.parse(response.body)["items"]
      items.concat(page)
      offset += PLAYLISTS_PAGE_SIZE
      break if page.size < PLAYLISTS_PAGE_SIZE
    end

    items
  end

  def musicbuddy_playlists
    playlists.select { |playlist| playlist["name"].to_s.downcase.include?(MUSICBUDDY_TERM) }
  end

  private

  def raise_api_error(response)
    raise ApiError.new("Spotify API error (#{response.status})", status: response.status)
  end

  def connection
    Faraday.new(url: API_BASE) do |f|
      f.headers["Authorization"] = "Bearer #{access_token}"
      f.headers["Content-Type"] = "application/json"
      f.adapter Faraday.default_adapter
    end
  end
end
