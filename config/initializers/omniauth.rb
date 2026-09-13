Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id),
    Rails.application.credentials.dig(:google, :client_secret)

  provider :spotify,
    Rails.application.credentials.dig(:spotify, :client_id),
    Rails.application.credentials.dig(:spotify, :client_secret),
    scope: "user-read-email user-read-private playlist-read-private playlist-read-collaborative playlist-modify-public playlist-modify-private"
end

OmniAuth.config.allowed_request_methods = [:post]
