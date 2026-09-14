Rails.application.routes.draw do
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Spotify routes must precede the generic :provider callback so they don't get swallowed by it.
  get "/auth/spotify/callback" => "spotify_connections#create"
  delete "/spotify_connection" => "spotify_connections#destroy", as: :disconnect_spotify

  get "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure" => "sessions#failure"
  delete "/logout" => "sessions#destroy", as: :logout
  get "/me" => "users#show", as: :profile
  resources :spotify_playlists, only: [ :index, :create, :destroy ]
  resources :ai_chats, only: [ :create, :destroy ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
